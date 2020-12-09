import UIKit

public protocol DraggableViewDelegate: class {
  func didDragCompletely()
}

public class DraggableView: UIView {

  private weak var gestureArea: UIView!
  private weak var parentView: UIView!
  private var axis: NSLayoutConstraint.Axis!
  private var containerInitialOrigin: CGPoint!

  weak var delegate: DraggableViewDelegate?

  public func setup(gestureArea: UIView,
                    parentView: UIView,
                    axis: NSLayoutConstraint.Axis = .vertical,
                    delegate: DraggableViewDelegate? = nil) {

    self.gestureArea = gestureArea
    self.parentView = parentView
    self.delegate = delegate
    self.axis = axis

    containerInitialOrigin = frame.origin

    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
    gestureArea.addGestureRecognizer(panGesture)
  }

  @objc private func handleGesture(_ sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: parentView)

    switch axis {
    case .vertical:
      handleVertical(panGesture: sender, containerViewFrame: frame, translation: translation)
    case .horizontal:
      handleHorizontal(panGesture: sender, containerViewFrame: frame, translation: translation)
    default:
      break
    }

    sender.setTranslation(.zero, in: parentView)
  }

  private func handleHorizontal(panGesture: UIPanGestureRecognizer, containerViewFrame: CGRect, translation: CGPoint) {
    let moveOffset = translation.x
    let containerInitialPosition = containerInitialOrigin.x
    var newPosition = containerViewFrame.origin.x + moveOffset

    // Prevent drag up more than the initial position
    if newPosition > containerInitialPosition {
      newPosition = containerInitialPosition
    }

    moveContainer(newPosition: newPosition)

    // Drag it left or right completely based on the gesture being done
    // until after or before the half of the height of the container view
    guard panGesture.state == .ended else { return }

    var didDragLeftCompletely = false

    if newPosition < -(containerViewFrame.width / 2) {
      newPosition = -(parentView.frame.width)
      didDragLeftCompletely = true
    } else {
      newPosition = containerInitialPosition
    }

    animateStateEnded(newPosition: newPosition, completedGesture: didDragLeftCompletely)
  }

  private func handleVertical(panGesture: UIPanGestureRecognizer, containerViewFrame: CGRect, translation: CGPoint) {
    let moveOffset = translation.y
    let containerInitialPosition = containerInitialOrigin.y
    var newPosition = containerViewFrame.origin.y + moveOffset

    // Prevent drag up more than the initial position
    if newPosition < containerInitialPosition {
      newPosition = containerInitialPosition
    }

    moveContainer(newPosition: newPosition)

    // Drag it down or up completely based on the gesture being done
    // until after or before the half of the height of the container view
    guard panGesture.state == .ended else { return }

    var didDragDownCompletely = false

    if newPosition > (containerInitialPosition + containerViewFrame.height / 2) {
      newPosition = parentView.frame.height
      didDragDownCompletely = true
    } else {
      newPosition = containerInitialPosition
    }

    animateStateEnded(newPosition: newPosition, completedGesture: didDragDownCompletely)
  }

  private func animateStateEnded(newPosition: CGFloat, completedGesture: Bool) {
    UIView.animate(withDuration: 0.2, animations: {
      self.moveContainer(newPosition: newPosition)
    }, completion: { _ in
      if completedGesture {
        self.delegate?.didDragCompletely()
      }
    })
  }

  private func moveContainer(newPosition: CGFloat) {
    let containerViewFrame = frame
    switch axis {
    case .vertical:
      frame = CGRect(x: containerViewFrame.origin.x,
                     y: newPosition,
                     width: containerViewFrame.width,
                     height: containerViewFrame.height)
    case .horizontal:
      frame = CGRect(x: newPosition,
                     y: containerViewFrame.origin.y,
                     width: containerViewFrame.width,
                     height: containerViewFrame.height)
    default:
      break
    }

  }
}
