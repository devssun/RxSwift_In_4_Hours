//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by 최혜선 on 2020/04/19.
//  Copyright © 2020 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

class MenuListViewModel {
    // [menu]를 받는 observable
    var menuObservable = BehaviorSubject<[Menu]>(value: [])
    
    lazy var itemsCount = menuObservable.map {
        $0.map { $0.count }.reduce(0, +)
    }
    
    // 메뉴의 count가 바뀌면 즉 observable이 바뀌면 총합을 다시 계산을 한다
    lazy var totalPrice = menuObservable.map {
        $0.map { $0.price * $0.count }.reduce(0, +)
    }
    
    // Subject - observable처럼 값을 받을 수도 있지만 값을 통제할 수도 있음
    init() {
        _ = APIService.fetchAllMenusRx()
            .map { data -> [MenuItem] in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                let response = try! JSONDecoder().decode(Response.self, from: data)
                
                return response.menus
        }
        .map { menuItems -> [Menu] in
            var menus: [Menu] = []
            menuItems.enumerated().forEach { (index, item) in
                let menu = Menu.fromMenuItems(id: index, item: item)
                menus.append(menu)
            }
            return menus
        }
        .take(1)
        .bind(to: menuObservable)
    }
    
    func clearAllItemSelections() {
        _ = menuObservable
            .map { menus in
                return menus.map { m in
                    Menu(id: m.id, name: m.name, price: m.price, count: 0)
                }
        }
        .take(1)
        .subscribe(onNext: {
            self.menuObservable.onNext($0)
        })
    }
    
    func changeCount(item: Menu, increase: Int) {
        _ = menuObservable
            .map { menus in
                return menus.map { m in
                    if m.id == item.id {
                        return Menu(id: m.id,
                                    name: m.name,
                                    price: m.price,
                                    count: max(m.count + increase, 0))
                    }
                    return Menu(id: m.id,
                                name: m.name,
                                price: m.price,
                                count: m.count)
                }
        }
        .take(1)
        .subscribe(onNext: {
            self.menuObservable.onNext($0)
        })
    }
    
    func onOrder() {
        
    }
}
