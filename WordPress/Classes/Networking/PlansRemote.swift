import Foundation

class PlansRemote: ServiceRemoteREST {
    typealias SitePlans = (activePlan: Plan, availablePlans: [Plan])
    enum Error: ErrorType {
        case DecodeError
        case UnsupportedPlan
        case NoActivePlan
    }


    func getPlansForSite(siteID: Int, success: SitePlans -> Void, failure: ErrorType -> Void) {
        let endpoint = "sites/\(siteID)/plans"
        let path = pathForEndpoint(endpoint, withVersion: ServiceRemoteRESTApiVersion_1_2)

        api.GET(path,
            parameters: nil,
            success: {
                _, response in
                do {
                    try success(mapPlansResponse(response))
                } catch {
                    failure(error)
                }
            }, failure: {
                _, error in
                failure(error)
        })
    }

}

private func mapPlansResponse(response: AnyObject) throws -> (activePlan: Plan, availablePlans: [Plan]) {
    guard let json = response as? [[String: AnyObject]] else {
        throw PlansRemote.Error.DecodeError
    }

    let parsedResponse: (Plan?, [Plan]) = try json.reduce((nil, []), combine: {
        (result, planDetails: [String: AnyObject]) in
        guard let planId = planDetails["product_id"] as? Int else {
            throw PlansRemote.Error.DecodeError
        }
        guard let plan = defaultPlans.withID(planId) else {
            throw PlansRemote.Error.UnsupportedPlan
        }
  
        if let featureGroupsJson = planDetails["features_highlight"] as? [[String: AnyObject]] {
            try parseFeatureGroups(featureGroupsJson, forPlan: plan)
        }
        
        let plans = result.1 + [plan]
        if let isCurrent = planDetails["current_plan"] as? Bool where
            isCurrent {
            return (plan, plans)
        } else {
            return (result.0, plans)
        }
    })
    
    guard let activePlan = parsedResponse.0 else {
        throw PlansRemote.Error.NoActivePlan
    }
    let availablePlans = parsedResponse.1.sort()
    return (activePlan, availablePlans)
}

private func parseFeatureGroups(json: [[String: AnyObject]], forPlan plan: Plan) throws {
    let groups: [PlanFeatureGroup] = try json.flatMap { groupJson in
        guard let slugs = groupJson["items"] as? [String] else { throw PlansRemote.Error.DecodeError }
        return PlanFeatureGroup(title: groupJson["title"] as? String, slugs: slugs)
    }
    
    PlanFeatureGroup.setGroups(groups, forPlan: plan)
}

class PlanFeaturesRemote: ServiceRemoteREST {
    
    enum Error: ErrorType {
        case DecodeError
    }
    
    private var cacheDate: NSDate?
    private let cacheFilename = "plan-features.json"
    
    func getPlanFeatures(success: PlanFeatures -> Void, failure: ErrorType -> Void) {
        // First we'll try and return plan features from memory, then check our disk cache,
        // and finally hit the network if we don't have anything recent enough
        if let planFeatures = inMemoryPlanFeatures {
            success(planFeatures)
            return
        }
        
        // If we have features cached to disk, update the in-memory list and the cache date to match
        if let (planFeatures, date) = cachedPlanFeaturesWithDate() {
            inMemoryPlanFeatures = planFeatures
            cacheDate = date
            
            success(planFeatures)
            return
        }
        
        fetchPlanFeatures({ [weak self] planFeatures in
            self?.inMemoryPlanFeatures = planFeatures
            self?.cacheDate = NSDate()
            
            success(planFeatures)
        }, failure: failure)
    }
    
    private var _planFeatures: PlanFeatures?
    private var inMemoryPlanFeatures: PlanFeatures? {
        get {
            // If we have something in memory and it's less than a day old, return it.
            if let planFeatures = _planFeatures,
                let cacheDate = cacheDate where
                cacheDateIsValid(cacheDate) {
                    return planFeatures
            }
            
            return nil
        }
        
        set {
            _planFeatures = newValue
        }
    }
    
    private func cachedPlanFeatures() -> PlanFeatures? {
        guard let (planFeatures, _) = cachedPlanFeaturesWithDate() else { return nil}

        return planFeatures
    }
    
    /// @return An optional tuple containing a collection of cached plan features and the date when they were fetched
    private func cachedPlanFeaturesWithDate() -> (PlanFeatures, NSDate)? {
        if let cacheFileURL = cacheFileURL,
            let path = cacheFileURL.path {
                
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                do {
                    let attributes = try NSFileManager.defaultManager().attributesOfItemAtPath(path)
                    if let modificationDate = attributes[NSFileModificationDate] as? NSDate {
                        if cacheDateIsValid(modificationDate) {
                            if let response = NSData(contentsOfURL: cacheFileURL) {
                                let json = try NSJSONSerialization.JSONObjectWithData(response, options: [])
                                return (try mapPlanFeaturesResponse(json), modificationDate)
                            }
                        }
                    }
                }
                catch {}
            }
        }
        
        return nil
    }
    
    private func cacheDateIsValid(date: NSDate) -> Bool {
        return NSCalendar.currentCalendar().isDateInToday(date)
    }
    
    private func fetchPlanFeatures(success: PlanFeatures -> Void, failure: ErrorType -> Void) {
        let endpoint = "plans/features"
        let path = pathForEndpoint(endpoint, withVersion: ServiceRemoteRESTApiVersion_1_2)
        
        api.GET(path,
            parameters: nil,
            success: {
                [weak self] requestOperation, response in
                self?.cacheResponseData(requestOperation.responseData)
                do {
                    try success(mapPlanFeaturesResponse(response))
                } catch {
                    failure(error)
                }
            }, failure: {
                _, error in
                failure(error)
        })
    }
    
    private var cacheFileURL: NSURL? {
        guard let cacheDirectory = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first else { return nil }
        
        return cacheDirectory.URLByAppendingPathComponent(cacheFilename)
    }
    
    private func cacheResponseData(responseData: NSData?) {
        guard let responseData = responseData else { return }
        guard let cacheFileURL = cacheFileURL else { return }
        
        responseData.writeToURL(cacheFileURL, atomically: true)
    }
}

private func mapPlanFeaturesResponse(response: AnyObject) throws -> PlanFeatures {
    guard let json = response as? [[String: AnyObject]] else {
        throw PlansRemote.Error.DecodeError
    }
    
    var features = [PlanID: [PlanFeature]]()
    for featureDetails in json {
        guard let slug = featureDetails["product_slug"] as? String,
            let title = featureDetails["title"] as? String,
            var description = featureDetails["description"] as? String,
            let iconName = featureDetails["icon"] as? String,
            let planDetails = featureDetails["plans"] as? [String: AnyObject] else { throw PlansRemote.Error.DecodeError }
        
            for (planID, planInfo) in planDetails {
                guard let planID = Int(planID) else { throw PlansRemote.Error.DecodeError }

                if features[planID] == nil {
                    features[planID] = [PlanFeature]()
                }
                    
                if let planInfo = planInfo as? [String: String],
                    let planSpecificDescription = planInfo["description"] {
                        description = planSpecificDescription
                }
                
                features[planID]?.append(PlanFeature(slug: slug, title: title, description: description, iconName: iconName))
            }
    }
    
    return features
}
