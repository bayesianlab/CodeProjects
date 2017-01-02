import java.awt.*;

/**
 * Created by dillonflannery-valadez on 12/8/15.
 */
import java.awt.BasicStroke; import java.awt.Color; import java.awt.Graphics; import java.awt.Graphics2D;

public class Oval implements Sprite{
    private int x;
    private int y;
    private int width;
    private int height;
    private  Color color;

    public Oval(int x, int y, int width, int height, Color color){
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.color = color;
    }

    public void draw(Graphics surface, int leftX, int topY) {
        surface.setColor(color);
        surface.fillOval(leftX, topY, width, height);
        surface.setColor(Color.ORANGE);
        ((Graphics2D) surface).setStroke(new BasicStroke(3.0f));
        surface.drawOval(leftX, topY, width, height);
    }

    public int getWidth() {
        return width;
    }

    public int getHeight() {
        return height;
    }


}
