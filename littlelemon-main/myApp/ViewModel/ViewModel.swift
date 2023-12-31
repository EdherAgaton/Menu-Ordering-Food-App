

import Foundation
import CoreData

struct MenuHelpers {
    static func buildSortDescriptors() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedStandardCompare))]
    }

    static func buildPredicate(searchText: String, startersIsEnabled: Bool, mainsIsEnabled: Bool, dessertsIsEnabled: Bool, drinksIsEnabled: Bool) -> NSPredicate {
        var subpredicates: [NSPredicate] = []
        
        // Search text predicate
        if !searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            subpredicates.append(searchPredicate)
        }
        
        // Category filters
        if !startersIsEnabled {
            let startersPredicate = NSPredicate(format: "category != %@", "starters")
            subpredicates.append(startersPredicate)
        }
        if !mainsIsEnabled {
            let mainsPredicate = NSPredicate(format: "category != %@", "mains")
            subpredicates.append(mainsPredicate)
        }
        if !dessertsIsEnabled {
            let dessertsPredicate = NSPredicate(format: "category != %@", "desserts")
            subpredicates.append(dessertsPredicate)
        }
        if !drinksIsEnabled {
            let drinksPredicate = NSPredicate(format: "category != %@", "drinks")
            subpredicates.append(drinksPredicate)
        }
        
        // Combine subpredicates using AND operator
        return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
    }

    static func getMenuData(viewContext: NSManagedObjectContext) {
        PersistenceController.shared.clear()
        let serverURLString = "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json"
        let url = URL(string: serverURLString)
        guard let url = url else {
            print("Invalid server URL")
            return
        }
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let menuList = try decoder.decode(MenuList.self, from: data)
                    
                    for menuItem in menuList.menu {
                        let dish = DishEntity(context: viewContext)
                        dish.title = menuItem.title
                        dish.price = menuItem.price
                        dish.image = menuItem.image
                        dish.descriptionItem = menuItem.descriptionItem
                        dish.category = menuItem.category
                    }
                    try? viewContext.save()
                } catch {
                    print("Error decoding menu data: \(error)")
                }
            }
        }
        task.resume()
    }
}
