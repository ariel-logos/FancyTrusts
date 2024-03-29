# FancyTrusts

### What is it?
FancyTrusts is an add-on for FFXI's third-party loader and hook Ashita (https://www.ashitaxi.com/).

The purpose of this add-on is pretty straightforward: it's a fancy UI to manage trusts.
<br></br>

### How does it work?
This add-on uses ImGui to create an overlay that allows the player to easily perform some operations with trusts otherwise very tedious or not even possible.
<br></br>

### Main features
The add-on works in 2 main modes:
<ul>
	<li>${\textsf{\color{lime}{Direct summon}}}$: directly summons trusts when the relative buttons are clicked.</li>
	<li>${\textsf{\color{orange}{Preset summon}}}$: clicking on trusts buttons will add/remove them from the selected preset.</li>
</ul>

For more details see the Functionalities section further below.

![Mode 1](https://github.com/ariel-logos/FancyTrusts/assets/78350872/bb3bac77-ef96-488c-803b-f85179cf42e7) | ![Mode 2](https://github.com/ariel-logos/FancyTrusts/assets/78350872/aa9f98a2-784f-4993-9de9-06d9cf3aa8e4)
:------------------|------------------
Direct summon mode | Preset summon mode

### Installation
Go over the <a href="https://github.com/ariel-logos/FancyTrusts/releases" target="_blank">Releases</a> page, download the latest version and unpack it in the add-on folder in your Ashita installation folder. You should now have among the other add-on folders the "FancyTrusts" one!
<br></br>

### Compatibility Issues
No compatibility issues found so far.

### Functionalities

#### Commands
```/addon load FancyTrusts``` Loads the add-on in Ashita.

```/addon unload FancyTrusts``` Unloads the add-on from Ashita.

```/trusts``` Shows/hides the FancyTrusts UI. (Works better with a keybind in Ashita)

```/trusts pX``` Where X is a number from 1 to 5, in-game line command to summon a preset from 1 to 5.

```/trusts reset pX``` Where X is a number from 1 to 5, in-game line command to reset a preset from 1 to 5.
<br></br>
#### Trusts tab
This tab displays the list of your currently available trusts. It is possible to scroll, while hovering with the mouse cursor, in order to explore the full list.\
Additionally, it provides the possibility to create 5 different presets, using the circle-shaped checkboxes numbered from 1 to 5 on the right side.

When no checkboxes are selected, the UI is in ${\textsf{\color{lime}{Direct summon}}}$. This means that, by clicking any button with a trust name, the UI will immediatly attempt to summon that trust in the game. When one of the checkboxes is selected, the UI is in ${\textsf{\color{orange}{Preset summon}}}$. In this mode, clicking the buttons with trusts names, will add them (or remove them if they have been added previously) to the preset selected by the checkbox. The trusts in a preset will display a different button color. When in ${\textsf{\color{orange}{Preset summon}}}$, there's a new button available: the <b>Summon</b> button. When, clicking this button, the UI will attempt to summon the trusts in the selected preset one after another in a classic macro fashion. While summoning, the button <b>Summo</b> button will change into a <b>Stop</b> button. If this last one is pressed, the UI will stop the sequence of summoning trusts at the earliest convenience.\
All edited presets are saved automatically.

#### Config tab
In this tab you can adjust few add-on settings, in particular:
<ol>
  <li><b>Slow Mode:</b> this increases the delay between the summoning of trusts while in summoning in  ${\textsf{\color{orange}{Preset summon}}}$. Very useful when your casting time is slowed down (e.g. while under the effect of SAM's ability Hasso)</li>
  <li><b>Selected On Top:</b> when in ${\textsf{\color{orange}{Preset summon}}}$, shows the trusts buttons in the selected preset at the top of the list.</li>
  <li><b>Max Trusts:</b> set this to the maximum number of trusts you are allowed to summon. This will prevent the preset to contain more trusts than you can use.</li>
  <li><b>UI Scale:</b> changes the scale of the FancyTrusts UI.</li>
  <li><b>*NEW* Handheld Mode:</b> enables navigation buttons for handheld device that don't feature a scroll input to navigate the Trust's list. Please mind that, in this mode, the Selected On Top feature is automatically disabled for compatibility issues.</li>
</ol>
<p align="center">
<img src="https://github.com/ariel-logos/FancyTrusts/assets/78350872/c308832d-1895-4826-b628-d6f8c6f72d7c" alt="FancyTrusts Config tab"/>
</p>
