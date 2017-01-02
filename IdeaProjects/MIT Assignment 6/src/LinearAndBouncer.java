import java.awt.*;
import java.awt.Graphics;


/**
 * Created by dillonflannery-valadez on 12/14/15.
 */
public class LinearAndBouncer implements Mover{
    public int x;
    public int y;
    public int xDirection;
    public int yDirection;
    public Sprite sprite;

    public LinearAndBouncer(int startX, int startY, int xIncrement, int yIncrement, Sprite sprite){
        x = startX;
        y = startY;
        xDirection = xIncrement;
        yDirection = yIncrement;
        this.sprite = sprite;
    }

    @Override
    public void draw(Graphics surface) {
        sprite.draw(surface, x, y);
        x += xDirection;
        y += yDirection;
    }
}
