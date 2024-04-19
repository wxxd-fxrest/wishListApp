//
//  ViewController.swift
//  wishListApp
//
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - @IBOutlet
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var homeIcon: UIImageView!
    @IBOutlet weak var profileIcon: UIImageView!
    
    var currentViewController: UIViewController?
    let scale: CGFloat = 1.5 // 아이콘 확대 배율
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // 상태 바 텍스트 색상 설정
    }
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarUIdesign() // 탭 바 UI 디자인 설정
        resetIconOpacity() // 아이콘 투명도 초기화
        
        DispatchQueue.main.async {
            self.startPage() // 초기 페이지 로드
        }
    }

    
    // MARK: - Init
    func startPage() {
        guard let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") else { return }
        contentView.addSubview(homeVC.view)
        animateIcon(homeIcon) // 아이콘 애니메이션 효과
        homeVC.didMove(toParent: self)
        currentViewController = homeVC // 현재 뷰 컨트롤러 업데이트
    }


    // MARK: - Tab bar UI
    func tabBarUIdesign() {
        tabBarView.layer.cornerRadius = tabBarView.frame.size.height / 2
        tabBarView.clipsToBounds = true
    }

    
    // MARK: - Tab 버튼 클릭 처리
    @IBAction func onClickTabButton(_ sender: UIButton) {
        let tag = sender.tag
        print(tag)
        
        resetIconScaleAndOpacity() // 아이콘 크기와 투명도 초기화
        
        // 현재 뷰 컨트롤러 제거
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()
        
        // 선택된 탭에 따라 새로운 뷰 컨트롤러로 전환
        if tag == 2 {
            guard let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") else { return }
            contentView.addSubview(homeVC.view)
            animateIcon(homeIcon) // 아이콘 애니메이션 효과
            homeVC.didMove(toParent: self)
            currentViewController = homeVC // 현재 뷰 컨트롤러 업데이트
        } else if tag == 3 {
            guard let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") else { return }
            contentView.addSubview(profileVC.view)
            animateIcon(profileIcon) // 아이콘 애니메이션 효과
            profileVC.didMove(toParent: self)
            currentViewController = profileVC // 현재 뷰 컨트롤러 업데이트
        }
    }


    // MARK: - Icon 크기와 투명도 초기화
    func resetIconScaleAndOpacity() {
        [homeIcon, profileIcon].forEach { icon in
            UIView.animate(withDuration: 0.3) {
                icon.transform = .identity // 아이콘 크기 초기화
            }
        }
        
        resetIconOpacity() // 아이콘 투명도 초기화
    }
    
    
    // MARK: - Icon 투명도 초기화
    func resetIconOpacity() {
        [homeIcon, profileIcon].forEach { icon in
            icon.alpha = 0.8 // 아이콘 투명도 초기화
        }
    }
    
    
    // MARK: - Icon 애니메이션
    func animateIcon(_ icon: UIImageView) {
        UIView.animate(withDuration: 0.3) {
            icon.transform = CGAffineTransform(scaleX: self.scale, y: self.scale) // 아이콘 확대 애니메이션
            icon.alpha = 1.0 // 아이콘 투명도 설정
        }
    }
}
