import UIKit
import CoreData


class ListNotesViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var notesCountLbl: UILabel!
    private let searchController = UISearchController()
    
    private var filteredNotes: [Note] = []
    private var fetchedResuktsContoller: NSFetchedResultsController<Note>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        tableView.contentInset = .init(top: 0, left: 0, bottom: 30, right: 0)
        configureSearchBar()
        setupFetchedResultsController()
        refreshCountLbl()
    }
    
    func refreshCountLbl() {
        let count = fetchedResuktsContoller.sections![0].numberOfObjects
        
        notesCountLbl.text = "\(count) \(count == 1 ? "Note" : "Notes")"
     }
    func setupFetchedResultsController(filter: String? = nil) {
        fetchedResuktsContoller = CoreDataManager.shared.createNotesFetchedResultsController(filter: filter)
        fetchedResuktsContoller.delegate = self
        try? fetchedResuktsContoller.performFetch()
        refreshCountLbl()
        
    }
    
    private func configureSearchBar() {
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.delegate = self
    }
    
    @IBAction func createNewNoteClicked(_ sender: UIButton) {
        goToEditNote(createNote())
    }
    
    private func goToEditNote(_ note: Note) {
        let controller = storyboard?.instantiateViewController(identifier: EditNoteViewController.identifier) as! EditNoteViewController
        controller.note = note
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK:- Methods to implement
    private func createNote() -> Note {
        
        let note = CoreDataManager.shared.createNotre()
        
        // Update table
      
        
        return note
    }
    
    
    private func deleteNoteFromStorage(_ note: Note) {
        // TODO delete the note
        CoreDataManager.shared.deleteNote(note)
        
    }
    
}

// MARK: TableView Configuration
extension ListNotesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let notes = fetchedResuktsContoller.sections![section]
        return notes.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListNoteTableViewCell.identifier) as! ListNoteTableViewCell
        let note = fetchedResuktsContoller.object(at: indexPath)
        cell.setup(note: note)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = fetchedResuktsContoller.object(at: indexPath)
        goToEditNote(note)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = fetchedResuktsContoller.object(at: indexPath)
           
            deleteNoteFromStorage(note)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK:- Search Controller Configuration
extension ListNotesViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search("")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(searchBar.text ?? "")
    }
    
    func search(_ query: String) {
        if query.count >= 1 {
            setupFetchedResultsController(filter: query)
        } else{
            setupFetchedResultsController()
        }
        
        tableView.reloadData()
    }
}

extension ListNotesViewController : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert: tableView.insertRows(at: [newIndexPath!], with: .automatic)
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        default:
            tableView.reloadData()
            refreshCountLbl()
        }
    }
}

