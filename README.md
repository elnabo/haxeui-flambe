<p align="center">
  <img src="https://dl.dropboxusercontent.com/u/26678671/haxeui2-warning.png"/>
</p>

<a href="https://www.patreon.com/haxeui"><img src="https://dl.dropboxusercontent.com/u/26678671/patreon_button.png" title="Support this project on Patreon!"/></a>

<h2>haxeui-flambe</h2>
`haxeui-flambe` is the `Flambe` backend for HaxeUI.

<h2>Installation</h2>
 * `haxeui-flambe` has a dependency to <a href="https://github.com/haxeui/haxeui-core">`haxeui-core`</a>, and so that too must be installed.
 * `haxeui-flambe` also has a dependency to <a href="https://github.com/aduros/flambe">Flambe</a>, please refer to the installation instructions on their <a href="https://github.com/aduros/flambe">site</a>.
 
Eventually all these libs will become haxelibs, however, currently in their alpha form they do not even contain a `haxelib.json` file (for dependencies, etc) and therefore can only be used by downloading the source and using the `haxelib dev` command or by directly using the git versions using the `haxelib git` command (recommended). Eg:

```
haxelib git haxeui-core https://github.com/haxeui/haxeui-core
haxelib dev haxeui-flambe path/to/expanded/source/archive
```

<h2>Usage</h2>
The simplest method to create a new `Flambe` application that is HaxeUI ready is to use one of the <a href="https://github.com/haxeui/haxeui-templates">haxeui-templates</a>. These templates will allow you to start a new project rapidly with HaxeUI support baked in. 

If however you already have an existing application, then incorporating HaxeUI into that application is straightforward:

<h3>flambe.yaml</h3>
In order to use HaxeUI with an existing `Flambe` application you must add these libraries to your `flambe.yaml` configuration file as part of the `haxe_flags` attribute. Eg:

```yaml
# Additional flags to pass to the Haxe compiler.
# haxe_flags: -lib nape -D foobar
haxe_flags: -swf-header 800:600:60:FFFFFF -lib haxeui-core -lib haxeui-flambe
```

_Note: Currently you must also include `haxeui-core` explicitly during the alpha, eventually `haxelib.json` files will exist to take care of this dependency automatically._

<h3>Toolkit initialisation and usage</h3>
The `Flambe` system itself must be initialised and an asset pack loaded before HaxeUI can be initialised and used. This is done with code similar to:

```haxe
// Wind up all platform-specific stuff
System.init();

// Load up the compiled pack in the assets directory named "bootstrap"
var manifest = Manifest.fromAssets("bootstrap");
var loader = System.loadAssetPack(manifest);
loader.get(onAssetsLoaded);
```

Initialising the toolkit requires you to add these lines somewhere _before_ you start to actually use HaxeUI in your application but _after_ you have loaded the `Flambe` asset pack:
 
```haxe
private static function onAssetsLoaded(pack:AssetPack) {
    Toolkit.init( {
       assetPack: pack // let the toolkit know which asset pack we are using
    });
}
```

Once the toolkit is initialised you can add components using the methods specified <a href="https://github.com/haxeui/haxeui-core#adding-components-using-haxe-code">here</a>.

<h2>Flambe specifics</h2>

As well as using the generic `Screen.instance.addComponent`, it is also possible to add components directly using a `Flambe` entity. Eg:

```haxe
System.root.addChild(new Entity().add(main));
```

<h3>Initialisation options</h3>
The configuration options that may be passed to `Tookit.init()` are as follows:

```haxe
Toolkit.init({
    assetPack: pack // the asset pack to work with
});
```

<h2>Addtional resources</h2>
* <a href="http://haxeui.github.io/haxeui-api/">haxeui-api</a> - The HaxeUI api docs.
* <a href="https://github.com/haxeui/haxeui-guides">haxeui-guides</a> - Set of guides to working with HaxeUI and backends.
* <a href="https://github.com/haxeui/haxeui-demo">haxeui-demo</a> - Demo application written using HaxeUI.
* <a href="https://github.com/haxeui/haxeui-templates">haxeui-templates</a> - Set of templates for IDE's to allow quick project creation.
* <a href="https://github.com/haxeui/haxeui-bdd">haxeui-bdd</a> - A behaviour driven development engine written specifically for HaxeUI (uses <a href="https://github.com/haxeui/haxe-bdd">haxe-bdd</a> which is a gherkin/cucumber inspired project).
* <a href="https://www.youtube.com/watch?v=L8J8qrR2VSg&feature=youtu.be">WWX2016 presentation</a> - A presentation given at WWX2016 regarding HaxeUI.

