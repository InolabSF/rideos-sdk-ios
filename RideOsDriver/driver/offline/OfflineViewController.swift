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
import RideOsCommon
import RxSwift
import SideMenu

public class OfflineViewController: BackgroundMapViewController {
    private weak var goOnlineListener: GoOnlineListener?

    private let topDetailView = TopDetailView(frame: .zero)
    private let sideMenuManager: SideMenuManager
    private let disposeBag = DisposeBag()
    private let mapStateProvider = FollowCurrentLocationMapStateProvider(icon: DrawableMarkerIcons.car())
    private let viewModel: OfflineViewModel
    private let schedulerProvider: SchedulerProvider

    public init(goOnlineListener: GoOnlineListener,
                mapViewController: MapViewController,
                viewModel: OfflineViewModel = DefaultOfflineViewModel(),
                sideMenuManager: SideMenuManager = SideMenuManager.default,
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider()) {
        self.goOnlineListener = goOnlineListener
        self.sideMenuManager = sideMenuManager
        self.schedulerProvider = schedulerProvider
        self.viewModel = viewModel

        super.init(mapViewController: mapViewController, showSettingsButton: false)
    }

    required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(topDetailView)
        topDetailView.translatesAutoresizingMaskIntoConstraints = false
        topDetailView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        topDetailView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topDetailView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topDetailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 66.0).isActive = true

        topDetailView
            .menuButtonTapEvents
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [unowned self] in
                guard let sideMenuNavigationController = self.sideMenuManager.menuLeftNavigationController else {
                    logError("Side menu manager is missing left navigation controller. Not showing side menu.")
                    return
                }
                self.present(sideMenuNavigationController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        topDetailView.driverStatusSwitchValueChangedEvents
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [topDetailView, viewModel] in
                if topDetailView.isDriverStatusSwitchOn {
                    viewModel.goOnline()
                }
            }).disposed(by: disposeBag)

        viewModel.offlineViewState
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [unowned self] currentState in
                switch currentState {
                case .online:
                    self.goOnlineListener?.didGoOnline()
                case .failedToGoOnline:
                    self.topDetailView.setDriverStatusSwitch(isOn: false, animated: true)
                    self.present(self.goingOnlineFailedAlertController(),
                                 animated: true,
                                 completion: nil)
                default:
                    break
                }

            }).disposed(by: disposeBag)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mapViewController.connect(mapStateProvider: mapStateProvider)
    }
}

extension OfflineViewController {
    private func goingOnlineFailedAlertController() -> UIAlertController {
        let alertController = UIAlertController(
            title: RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.offline.go-online-failed-alert.title"
            ),
            message: RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.offline.go-online-failed-alert.message"
            ),
            preferredStyle: UIAlertController.Style.alert
        )

        alertController.addAction(
            UIAlertAction(
                title: RideOsDriverResourceLoader.instance.getString(
                    "ai.rideos.driver.offline.go-online-failed-alert.action.ok"
                ),
                style: UIAlertAction.Style.default
            )
        )
        return alertController
    }
}
