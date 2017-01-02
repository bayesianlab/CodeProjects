/**
 * Created by dillonflannery-valadez on 11/21/15.
 */
import java.awt.Graphics;


public class StraightMover implements Mover {
   LinearAndBouncer linear ;

    /** Create a Bouncer that positions sprite at (startX, startY). */
    public StraightMover(int startX, int startY, int xIncrement, int yIncrement, Sprite sprite) {
        linear = new LinearAndBouncer(startX, startY, xIncrement, yIncrement, sprite);
    }

    public void draw(Graphics graphics) {
        linear.sprite.draw(graphics, linear.x, linear.y);
        // Move the center of the object each time we draw it
        linear.x += linear.xDirection;
        linear.y += linear.yDirection;
    }
}

