
part of PanelEditor;

class Group
{
	List<Panel>		_panels;
	String			_color;
	
	Group(String this._color)
	{
		_panels = new List<Panel>();
	}
	
	void	addPanel(Panel panel)
	{
		if (panel != null && !_panels.contains(panel)) {
			_panels.add(panel);
			panel.group = this;
		}
	}
	
	void	removePanel(Panel panel)
	{
		_panels.remove(panel);
	}
	
	get	panels	=>	_panels;
	get	color	=>	_color;
}