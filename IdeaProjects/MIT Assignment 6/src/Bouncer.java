/**
 * Created by dillonflannery-valadez on 11/21/15.
 */
import javax.sound.sampled.Line;
import java.awt.Graphics;
import java.awt.Graphics;

public class Bouncer implements Mover{
    LinearAndBouncer aBouncer;

    public Bouncer(int startX, int startY, int xIncrement, int yIncrement, Sprite sprite){
        aBouncer = new LinearAndBouncer(startX, startY, xIncrement, yIncrement, sprite);
    }

    /** Draws the sprite at its current position on to surface. */
    public void draw(Graphics surface) {
        // Draw the sprite
        aBouncer.sprite.draw(surface, aBouncer.x, aBouncer.y);

        // Move the object each time we draw it
        aBouncer.x += aBouncer.xDirection;
        aBouncer.y += aBouncer.yDirection;

        // If we have hit the edge and are moving in the wrong direction, reverse direction
        // We check the direction because if a box is placed near the wall, we would get "stuck"
        // rather than moving in the right direction
        if ((aBouncer.x <= 0 && aBouncer.xDirection < 0) ||
                (aBouncer.x + aBouncer.sprite.getWidth() >= SimpleDraw.WIDTH && aBouncer.xDirection > 0)) {
            aBouncer.xDirection = -aBouncer.xDirection;
        }
        if ((aBouncer.y <= 0 && aBouncer.yDirection < 0) ||
                (aBouncer.y + aBouncer.sprite.getHeight() >= SimpleDraw.HEIGHT && aBouncer.yDirection > 0)) {
            aBouncer.yDirection = -aBouncer.yDirection;
        }
    }
}