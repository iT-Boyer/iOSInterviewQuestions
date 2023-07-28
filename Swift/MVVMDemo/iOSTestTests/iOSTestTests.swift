//
//  iOSTestTests.swift
//  iOSTestTests
//
//  Created by chenyilong on 2023/7/2.
//

import XCTest
@testable import iOSTest

final class iOSTestTests: XCTestCase {
    var apiRepository: ApiRepository!
    var homeRowViewModel: PostListViewModel!
    var detailVC: PostDetailViewController!
    var post: Post!
    var emptyData : Data!
    var errorData : Data!
    var rightPostData : Data!
    var nilData : Data!
    var rightCommentData : Data!
    var urlSession: URLSession!
    var commentRowViewModel: CommentListViewModel!
    var comment: Comment!
    var viewController: PostListViewController!
    var rootNavigationController: UINavigationController!
    var timeoutForExpectationFulfilled: TimeInterval!

    override func setUpWithError() throws {

        timeoutForExpectationFulfilled = 60.0
        
        post = Post(id: 1, userId: 1, title: "Test Title", body: "Test Body") // or fetch a post from API
        
        detailVC = PostDetailViewController(model: post)
        detailVC.loadViewIfNeeded() // load the view hierarchy so you can test its elements
        
        // Set url session for mock networking
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
        // API Injected with custom url session for mocking
        apiRepository = ApiRepository(urlSession: urlSession)
        homeRowViewModel = PostListViewModel(repository: apiRepository)
        
        emptyData = try loadJson(filename: "emptyData")
        errorData = try loadJson(filename: "errorData")
        rightPostData = try loadJson(filename: "rightPostData")
        rightCommentData = try loadJson(filename: "rightCommentData")
        
        nilData = try loadJson(filename: "nilData")
        
        
        commentRowViewModel = CommentListViewModel(postId: post.id, repository: apiRepository)
        comment = Comment(postId: 1, id: 1, name: "id labore ex et quam laborum", body: "laudantium enim quasi est quidem magnam voluptate ipsam eos\ntempora quo necessitatibus\ndolor quam autem quasi\nreiciendis et nam sapiente accusantium", email: "Eliseo@gardner.biz")
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        viewController = PostListViewController()
        viewController.loadViewIfNeeded()
        
        rootNavigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = rootNavigationController
        
        window.makeKeyAndVisible()
        RunLoop.current.run(until: Date())
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        apiRepository = nil
        homeRowViewModel = nil
        post = nil
        detailVC = nil
        emptyData = nil
        errorData = nil
        rightPostData = nil
        rightCommentData = nil
        nilData = nil
        commentRowViewModel = nil
        comment = nil
        viewController = nil
        rootNavigationController = nil
    }

    func loadJson(filename fileName: String) throws -> Data {
        guard let pathString = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json") else {
            fatalError("UnitTestData.json not found")
        }
        
        guard let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8) else {
            fatalError("Unable to convert UnitTestData.json to String")
        }
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            fatalError("Unable to convert UnitTestData.json to Data")
        }
        return jsonData
    }
    
    // MARK: test Network Error for Posts request
    func testFetchHomePostsContent() {
        // Set mock data
        
        let mockData = rightPostData!
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData, nil)
        }
        
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Download contents from api")
        Task {
            do {
                let contents = try await apiRepository.fetchPosts()
                // use contents here
                XCTAssertFalse(contents.isEmpty, "Posts array should not be empty")
            } catch {
                // handle error
                XCTFail("Error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        // Wait until the expectation is fulfilled, with a timeout of seconds.
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
    func testFetchHomePostsContentEmptyData() throws {
        
        // Set mock data
        let mockData = emptyData!
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData, nil)
        }
        
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")
        
        // Make mock network request to get result from local file
        
        Task {
            do {
                let contents = try await apiRepository.fetchPosts()
                // use contents here
                XCTAssertTrue(contents.isEmpty, "Posts array should be empty")
            } catch {
                // handle error
                XCTFail("Error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        // Wait until the expectation is fulfilled, with a timeout of seconds.
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
    func testFetchHomePostsContentErrorData() throws {
        // Set mock data
        
        let mockData = errorData!
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData, nil)
        }
        
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")
        
        // Make mock network request to get result from local file
        Task {
            do {
                let contents = try await apiRepository.fetchPosts()
                XCTAssertTrue(contents.isEmpty, "Posts array should be empty")
            } catch {
                XCTAssertNotNil(error, "Posts array should be error")
            }
            expectation.fulfill()
        }
        
        // Wait until the expectation is fulfilled, with a timeout of seconds.
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
    func testFetchHomePostsContentRightData() throws {
        
        // Set mock data
        
        let mockData = rightPostData!
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            let errorTemp = NSError(domain:"", code:0, userInfo:nil)
            return (HTTPURLResponse(), mockData, errorTemp)
        }
        
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")
        // Make mock network request to get result from local file
        Task {
            do {
                let contents = try await apiRepository.fetchPosts()
                // use contents here
                XCTAssertTrue(contents.isEmpty, "Posts array should be empty")
            } catch {
                // handle error
                XCTAssertNotNil(error, "Posts array should be error")
            }
            expectation.fulfill()
        }
        // Wait until the expectation is fulfilled, with a timeout of seconds.
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
    func testFetchHomePostsContentNilData() throws {
        
        // Set mock data
        
        let mockData : Data? = nilData
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            let errorTemp = NSError(domain:"", code:0, userInfo:nil)
            return (HTTPURLResponse(), mockData, errorTemp)
        }
        
        // Set expectation. Used to test async code.
        // Make mock network request to get result from local file
        let expectation = XCTestExpectation(description: "response")
        Task {
            do {
                let contents = try await apiRepository.fetchPosts()
                XCTAssertTrue(contents.isEmpty, "Posts array should be empty")
            } catch {
                // handle error
                XCTAssertNotNil(error, "Posts array should be error")
            }
            expectation.fulfill()
        }
        // Wait until the expectation is fulfilled, with a timeout of seconds.
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
    func testPostDetailPress() {
        clickPostDetail(post: self.post, detailVC: self.detailVC)
    }
    
    func clickPostDetail(post: Post, detailVC :PostDetailViewController) {
        let expectation = XCTestExpectation(description: "response")
        DispatchQueue.main.async {
            detailVC.loadViewIfNeeded()
            if let viewController = self.viewController {
                viewController.tableView(viewController.tableView ?? UITableView(), didSelectRowAt: IndexPath(row: 0, section: 0)
                )
                
                self.rootNavigationController.pushViewController(detailVC, animated: true)
                XCTAssertEqual(detailVC.model.title, post.title)
                XCTAssertEqual(detailVC.model.body, post.body)
                expectation.fulfill()
                
            }
        }
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
    func testHomePostsContentFilter() {
        
        // Set mock data
        
        let mockData = rightPostData!
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData, nil)
        }
        
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Download contents from api")
        
        Task {
            do {
                try await homeRowViewModel.update()
                switch homeRowViewModel.viewState.value {
                    
                case .loading:
                    break
                    
                case .loaded:
                    XCTAssertTrue(((homeRowViewModel.contents.value.isEmpty) == false), "Posts array should not be empty!")
                    
                    var filterString = String(describing: UInt8.max)
                    homeRowViewModel.filterContentForSearchText(filterString)
                    XCTAssertTrue(((homeRowViewModel.contents.value.isEmpty) == true),  "Filter Posts array should not contain :" + filterString)
                    
                    homeRowViewModel.resetFilters()
                    XCTAssertTrue(((homeRowViewModel.contents.value.isEmpty) == false), "Reset Posts array should not be empty")
                    
                    filterString = "s"
                    homeRowViewModel.filterContentForSearchText(filterString)
                    for post in homeRowViewModel.contents.value  {
                        let isContain = post.title.lowercased().contains(filterString.lowercased())
                        XCTAssertTrue(isContain == true, post.title.lowercased() + "Filter Posts array should contain:" + filterString)
                    }
                    
                    filterString = ""
                    homeRowViewModel.filterContentForSearchText(filterString)
                    XCTAssertTrue(((homeRowViewModel.contents.value.isEmpty) == false), "Reset Posts array should not be empty")
                    
                    let post : Post = (homeRowViewModel.contents.value[0])
                    //TODO: await?
                    let detailVC = await PostDetailViewController(model: post)
                    
                    clickPostDetail(post: post, detailVC: detailVC)
                    break
                    
                default:
                    break
                }
            } catch {
                print("Update error: \(error.localizedDescription)")
            }
            
            // Fulfill the expectation to indicate that the background task has finished successfully.
            expectation.fulfill()
        }
        
        // Wait until the expectation is fulfilled, with a timeout of seconds.
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
    func testCommentsFilter() {
        
        // Set mock data
        
        let mockData = rightCommentData!
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData, nil)
        }
        
        
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Download contents from api")
        
        Task {
            do {
                try await commentRowViewModel.update()
                
                switch commentRowViewModel.viewState.value {
                    
                case .loading:
                    break
                    
                case .loaded:
                    XCTAssertTrue(((commentRowViewModel.contents.value.isEmpty) == false), "Posts array should not be empty!")
                    
                    var filterString = String(describing: UInt8.max)
                    commentRowViewModel.filterContentForSearchText(filterString)
                    XCTAssertTrue(((commentRowViewModel.contents.value.isEmpty) == true),  "Filter Posts array should not contain :" + filterString)
                    
                    commentRowViewModel.resetFilters()
                    XCTAssertTrue(((commentRowViewModel.contents.value.isEmpty) == false), "Reset Posts array should not be empty")
                    
                    filterString = "s"
                    commentRowViewModel.filterContentForSearchText(filterString)
                    for comment in commentRowViewModel.contents.value  {
                        let isContain = comment.body.lowercased().contains(filterString.lowercased())
                        XCTAssertTrue(isContain == true, comment.body.lowercased() + "Filter Posts array should contain:" + filterString)
                    }
                    
                    filterString = ""
                    commentRowViewModel.filterContentForSearchText(filterString)
                    XCTAssertTrue(((commentRowViewModel.contents.value.isEmpty) == false), "Reset Posts array should not be empty")
                    //                let comment : Post = (self?.commentRowViewModel.contents.value[0])!
                    //                let detailVC = CommentDetailViewController(model: comment)
                    //                self?.clickPostDetail(post: comment, detailVC: detailVC)
                    
                    break
                default:
                    break
                }
                
                // Fulfill the expectation to indicate that the background task has finished successfully.
                expectation.fulfill()
                
            } catch {
                print("Update error: \(error.localizedDescription)")
            }
        }
        // Wait until the expectation is fulfilled, with a timeout of seconds.
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
    // MARK: test Network Error for Comments request
    
    func testFetchCommentsContent() {
        // Set mock data
        let mockData = rightCommentData!
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData, nil)
        }
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Download contents from api")
        Task {
            do {
                let contents = try await apiRepository.fetchComments(id: post.id)
                XCTAssertFalse(contents.isEmpty, "Comments array should not be empty")
            } catch {
                XCTFail("Error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        // Wait until the expectation is fulfilled, with a timeout of seconds.
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
    func testFetchCommentsContentEmptyData() throws {
        
        // Set mock data
        let mockData = emptyData!
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData, nil)
        }
        
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")
        
        // Make mock network request to get result from local file
        Task {
            do {
                let contents = try await apiRepository.fetchComments(id: post.id)
                XCTAssertTrue(contents.isEmpty, "Comments array should be empty")
                
            } catch {
                XCTFail("Error: \(error.localizedDescription)")
            }
            // Fulfill the expectation to indicate that the background task has finished successfully.
            expectation.fulfill()
        }
        
        // Wait until the expectation is fulfilled, with a timeout of seconds.
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
    
    func testFetchCommentsContentErrorData() throws {
        // Set mock data
        
        let mockData = errorData!
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData, nil)
        }
        
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")
        
        // Make mock network request to get result from local file
        Task {
            do {
                let contents = try await apiRepository.fetchComments(id: post.id)
                XCTAssertTrue(contents.isEmpty, "Posts array should be empty")
                
            } catch {
                XCTAssertNotNil(error, "Posts array should be error")
            }
            // Fulfill the expectation to indicate that the background task has finished successfully.
            expectation.fulfill()
        }
        
        // Wait until the expectation is fulfilled, with a timeout of seconds.
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
    func testFetchCommentsContentRightData() throws {
        
        // Set mock data
        
        let mockData = rightPostData!
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            let errorTemp = NSError(domain:"", code:0, userInfo:nil)
            return (HTTPURLResponse(), mockData, errorTemp)
        }
        
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")
        
        // Make mock network request to get result from local file
        Task {
            do {
                let contents = try await apiRepository.fetchComments(id: post.id)
                XCTAssertTrue(contents.isEmpty, "Posts array should be empty")
                
            } catch {
                
                XCTAssertNotNil(error, "Posts array should be error")
            }
            // Fulfill the expectation to indicate that the background task has finished successfully.
            expectation.fulfill()
        }
        
        // Wait until the expectation is fulfilled, with a timeout of seconds.
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
    func testFetchCommentsContentNilData() throws {
        
        // Set mock data
        
        let mockData : Data? = nilData
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            let errorTemp = NSError(domain:"", code:0, userInfo:nil)
            return (HTTPURLResponse(), mockData, errorTemp)
        }
        
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")
        
        // Make mock network request to get result from local file
        Task {
            do {
                let contents = try await apiRepository.fetchComments(id: post.id)
                XCTAssertTrue(contents.isEmpty, "Posts array should be empty")
                
            } catch {
                XCTAssertNotNil(error, "Posts array should be error")
            }
            // Fulfill the expectation to indicate that the background task has finished successfully.
            expectation.fulfill()
        }
        
        // Wait until the expectation is fulfilled, with a timeout of seconds.
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
    func testCommentListTableViewCell() throws {
        
    }
    
    
    func testCommentsDetailViewController() throws {
        let expectation = XCTestExpectation(description: "response")
        
        let detailVC = CommentDetailViewController(model: comment)
        DispatchQueue.main.async {
            detailVC.loadViewIfNeeded()
            
            if let viewController = self.viewController {
                viewController.loadViewIfNeeded()
                self.rootNavigationController.pushViewController(detailVC, animated: true)
                XCTAssertEqual(detailVC.title, self.comment.name)
                expectation.fulfill()
                
            }
        }
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
        
    }
    
    func testCommentsListViewController() throws {
        let expectation = XCTestExpectation(description: "response")
        
        let commentRowViewModel = CommentListViewModel(postId: post.id)
        
        let commentListViewController = CommentListViewController(viewModel: commentRowViewModel)
        DispatchQueue.main.async {
            commentListViewController.loadViewIfNeeded()
            
            if let viewController = self.viewController {
                viewController.loadViewIfNeeded()
                
                self.rootNavigationController.pushViewController(commentListViewController, animated: true)
                XCTAssertEqual(commentListViewController.title, "Comments")
                //                XCTAssertEqual(commentListViewController.viewModel.postId, self.comment.postId)
                
                commentListViewController.tableView(commentListViewController.tableView ?? UITableView(), didSelectRowAt: IndexPath(row: 0, section: 0))
                expectation.fulfill()
            }
            
        }
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
    func testCommentCellViewModel() throws {
        let commentCellViewModel = CommentCellViewModel(content: comment)
        XCTAssertEqual(commentCellViewModel.content.id, comment.id)
    }
    
    func testPostCellViewModel() throws {
        let homePostCellViewModel = PostCellViewModel(content: post)
        
        XCTAssertEqual( homePostCellViewModel.content.id, post.id)
    }
    
    func testObservable() throws {
        let expectation = XCTestExpectation(description: "response")
        var array = ["a"]
        let contents = Observable<[String]>(value: [])
        
        contents.addObserver(fireNow: false) { contents in
            XCTAssertEqual( contents[0] , array[0])
            XCTAssertEqual( contents[0] , "b")
            
            expectation.fulfill()
            
        }
        array = ["b"]
        contents.value = array
        wait(for: [expectation], timeout: timeoutForExpectationFulfilled)
    }
    
}
