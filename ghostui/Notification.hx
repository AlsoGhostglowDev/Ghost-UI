package ghostui;

import flixel.util.FlxTimer;
import flixel.tweens.*;

enum NotificationType {
    INFORMATION;
    WARNING;
    ERROR;
}

class Notification extends BasicUI {
    public var icon:FlxSprite;
    public var iconBG:FlxSprite;
    public var base:FlxSprite;
    public var text:FlxText;
    public var timerBar:FlxSprite;
    
    public function new(size:Float = 50, type:NotificationType, notifTxt:String) {
        super();

        base = new FlxSprite(size / 2, 0);
        base.makeGraphic(1, 1, 0xFFFFFFFF);
        base.color = 0xFF000000;
        base.alpha = 0.8;
        add(base);

        iconBG = new FlxSprite(0, 0);
        iconBG.makeGraphic(1, 1, 0xFFFFFFFF); 
        iconBG.color = getNotificationColor(type);
        add(iconBG);

		text = new FlxText((size / 2) + 8, 4, size * 3, notifTxt);
        text.setFormat(Config.labelFont, int(size * 0.25));
        add(text);

        base.scale.set(text.width + (size / 2), text.height + 4);
        base.updateHitbox();
        iconBG.scale.set(size / 2, base.scale.y);
        iconBG.updateHitbox();

		icon = new FlxSprite(0, 0, type == INFORMATION ? 'assets/images/info.png' : 'assets/images/caution.png');
		icon.setGraphicSize(iconBG.width - 8, iconBG.width - 8);
        icon.updateHitbox();
		icon.setPosition((iconBG.width - icon.width) / 2, (iconBG.height - icon.height) / 2);
		add(icon);

        timerBar = new FlxSprite(0, base.height - 3);
        timerBar.makeGraphic(int(base.width), 3, 0xFFFFFFFF);
        add(timerBar);
    }
    
    override public function update(elapsed:Float) {
        super.update(elapsed);
        if (timer != null) {
            timerBar.scale.x = 1 - timer.progress;
            timerBar.updateHitbox();
        } else
            timerBar.scale.x = 0;
    }

    public var timer:FlxTimer;
	static var instances:Array<Notification> = [];
    public static function spawnNotification(size:Float = 50, type:NotificationType, notifTxt:String):Notification {
        var notif = new Notification(size, type, notifTxt);
        notif.x -= notif.width;
        notif.y = FlxG.height - notif.height - 8;

		FlxTween.tween(notif, {x: 8, y: FlxG.height - notif.height - 8}, 1, {startDelay: 0.2, ease: FlxEase.expoOut});

        var collectedHeight:Float = 0;
        for (i in 0...instances.length) {
            var instance = instances[instances.length - i - 1];
            if (instance != null) {
                collectedHeight += instance.height + 8;
			    FlxTween.cancelTweensOf(instance.y);
                FlxTween.tween(instance, {y: FlxG.height - notif.height - collectedHeight - 8}, 0.8, {ease: FlxEase.expoOut});
            }
        }

        instances.push(notif);

        notif.timer = new FlxTimer().start(5, tmr -> {
            FlxTween.tween(notif, {x: -notif.width}, 0.6, {ease: FlxEase.expoIn, onComplete: twn -> {
                instances.remove(notif);
                notif.destroy();
            }});
			notif.timer = null;
        });

        return notif;
    }

    function getNotificationColor(type:NotificationType) {
        return switch(type) {
            case INFORMATION: 0xFF46ABFD;
            case WARNING: 0xFFFFBB00;
			case ERROR: 0xFFFF3831;
        }
    }
}