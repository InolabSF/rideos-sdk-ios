// Copyright 2019 rideOS, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

public struct PreTripLocation: Equatable {
    public let desiredAndAssignedLocation: DesiredAndAssignedLocation
    public let wasSetOnMap: Bool

    public init(desiredAndAssignedLocation: DesiredAndAssignedLocation, wasSetOnMap: Bool) {
        self.desiredAndAssignedLocation = desiredAndAssignedLocation
        self.wasSetOnMap = wasSetOnMap
    }

    public init?(desiredAndAssignedLocation: DesiredAndAssignedLocation?, wasSetOnMap: Bool = false) {
        if let desiredAndAssignedLocation = desiredAndAssignedLocation {
            self.desiredAndAssignedLocation = desiredAndAssignedLocation
            self.wasSetOnMap = wasSetOnMap
        } else {
            return nil
        }
    }
}
