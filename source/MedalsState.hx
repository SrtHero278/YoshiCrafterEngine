import Medals.MedalsJSON;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIText;
import flixel.math.FlxMath;
import haxe.Json;
import openfl.utils.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class MedalsState extends MusicBeatState {
    var bg:FlxSprite;
    var medals:MedalsJSON;
    var sprites:FlxTypedSpriteGroup<MedalSprite> = new FlxTypedSpriteGroup<MedalSprite>();
    var curSelected:Int = 0;
    var unlockedMedals:Int = 0;
    var desc:FlxUIText;
    var unlockedCaption:AlphabetOptimized;

    final multiple = 1;

    public override function create() {
        super.create();
        bg = CoolUtil.addBG(this);
        bg.scrollFactor.set();

        medals = ModSupport.modMedals[Settings.engineSettings.data.selectedMod];
        if (medals == null) {
            if (Assets.exists(Paths.file("medals.json", TEXT, 'mods/${Settings.engineSettings.data.selectedMod}'))) {
                ModSupport.modMedals[Settings.engineSettings.data.selectedMod] = medals = Json.parse(Assets.getText(Paths.file("medals.json", TEXT, 'mods/${Settings.engineSettings.data.selectedMod}')));
            } else {
                medals = ModSupport.modMedals[Settings.engineSettings.data.selectedMod] = {medals: []};
            }
        }
        if (medals.medals == null) medals.medals = [];
        for(k=>e in medals.medals) {
            var mSprite = new MedalSprite(Settings.engineSettings.data.selectedMod, e);
            mSprite.y = ((Math.floor(k / multiple)) * 125) + 25;
            sprites.add(mSprite);
            if (!mSprite.locked) unlockedMedals++;
        }
        add(sprites);

        var bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, 80, 0x88000000, true);
        add(bg);
        
        var title = new AlphabetOptimized(FlxG.width / 2, 17.5, "Medals", true, 0.75);
        title.x -= title.width / 2;
        add(title);

        unlockedCaption = new AlphabetOptimized(FlxG.width - 10, 20, '$unlockedMedals/${medals.medals.length}', false, 0.5);
        unlockedCaption.outline = true;
        add(unlockedCaption);

        desc = new FlxUIText(0, FlxG.height * 0.9, "");
        desc.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        desc.antialiasing = true;
        add(desc);

        bg.scrollFactor.set();
        title.scrollFactor.set();
        unlockedCaption.scrollFactor.set();
        desc.scrollFactor.set();
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (controls.BACK) FlxG.switchState(new MainMenuState());

        var oldSelected = curSelected;
        if (controls.RIGHT_P) curSelected++;
        if (controls.LEFT_P) curSelected--;
        if (controls.DOWN_P) curSelected += multiple;
        if (controls.UP_P) curSelected -= multiple;
        curSelected = CoolUtil.wrapInt(curSelected, 0, sprites.length);
        if (curSelected != oldSelected) {
            CoolUtil.playMenuSFX(0);
            desc.alpha = 0;
            desc.offset.y = 25;
        }
        var descLerpRatio = 0.25 * elapsed * 60;
        desc.offset.y = FlxMath.lerp(desc.offset.y, 0, descLerpRatio);
        desc.alpha = FlxMath.lerp(desc.alpha, 1, descLerpRatio);

        var l = elapsed * 0.25 * 60;

        sprites.y = FlxMath.lerp(sprites.y, -125 * (Math.floor(curSelected / multiple) + 0.5) + (FlxG.height / 2), l);

        for(k=>e in sprites.members) {
            e.alpha = FlxMath.lerp(e.alpha, (k == curSelected) ? 1 : 0.3, l);
            if (k == curSelected) {
                desc.text = medals.medals[k].desc;
                desc.x = e.img.x + e.img.width + 5;
                desc.y = e.img.y + (e.img.height * 0.5) + 5;
            }
            e.title.offset.y = FlxMath.lerp(e.title.offset.y, (k == curSelected) ? e.title.height / 2 + 10 : 0, descLerpRatio);
            e.x = (1 - (1 - Math.pow(Math.sin(FlxMath.bound((e.y + (e.height / 2)) / FlxG.height * Math.PI, 0, Math.PI)), 1.5))) * 75;
        }
        unlockedCaption.x = FlxG.width - 10 - unlockedCaption.width;
    }
}