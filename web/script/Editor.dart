
part of PanelEditor;

class Editor
{
	static const double			_scaleDelta = 0.1;
	double						_scale;
	ImageElement				_background;
	Template					_template;
	DivElement					_leftContainer;
	Panel						_movingPanel;
	Panel						_movingImage;
	Panel						_resizingPanel;
	List<Panel>					_panels;
	String						_patternName;
	Map<String, dynamic>		_config;
	List<Group>					_groups;
	bool						_skip;
	
	Editor({
		Template				template,
		double					scale: 1.00,
		ImageElement			background,
		Map<String, dynamic>	config
	})
	{
		_skip = false;
		_config = config;
		_scale = scale;
		_background = background;
		_template = template;
		_movingPanel = null;
		_movingImage = null;
		_panels = new List<Panel>();
		_groups = new List<Group>();
		
		if (!_skip)
			_template.showPatternSelection(buttonAction: (String patternName) {
				_patternName = patternName;
				_template.showEditor(
					callback: _configureTemplate
				);
			});
		
		document
			..onMouseMove.listen(_onMouseMove)
			..onMouseUp.listen(_onMouseUp)
		;
		

		if (_skip) {
			_patternName = 'monoptych';
			_template.showEditor(
				callback: _configureTemplate
			);
		}
	}
	
	Panel	_addPanel(Map<String, dynamic> config)
	{
		Panel					panel;
		Map<String, dynamic>	panelConfig;
		
		panelConfig = _config['panels'][config['name']];
		if (panelConfig == null)
			return null;
		
		panel = new Panel(
			editor: this,
			container: _leftContainer,
			image: _background,
			position: new Point(config['position']['x'], config['position']['y']),
			width: panelConfig['width'],
			height: panelConfig['height'],
			imagePosition: new Point(config['imagePosition']['x'], config['imagePosition']['y']),
			scale: _scale
		);
		
		_panels.add(panel);
		
		return panel;
	}
	
	void	_onMouseUp(MouseEvent e)
	{
		_movingPanel = null;
		_movingImage = null;
		_resizingPanel = null;
	}
	
	void	_onMouseMove(MouseEvent e)
	{
		int	x;
		int	y;

		if (_movingPanel != null) {
			if (_movingPanel.solo)
				_movingPanel.moveBy(e.movement.x, e.movement.y);
			else
				moveGroup(_movingPanel.group, e.movement);
		} else if (_movingImage != null) {
			if (_movingImage.solo)
				_movingImage.moveImageBy(e.movement);
			else
				moveGroupImage(_movingImage.group, e.movement);
		} else if (_resizingPanel != null) {
			_resizingPanel.resizeBy(e.movement);
		}
	}
	
	void	scaleGroupImages(Group group, WheelEvent e)
	{
		group.panels.forEach((Panel panel) {
			panel.scaleImage(e);
		});
	}
	
	void	moveGroup(Group group, Point delta)
	{
		group.panels.forEach((Panel panel) {
			panel.moveBy(delta.x, delta.y);
		});
	}
	
	void	moveGroupImage(Group group, Point delta)
	{
		group.panels.forEach((Panel panel) {
			panel.moveImageBy(delta);
		});
	}
	
	void	changeGroupImage(Group group, ImageElement image)
	{
		group.panels.forEach((Panel panel) {
			panel.image = image;
		});
	}
	
	void	changeBackground(Panel panel)
	{
		Element				el;
		List<ImageElement>	images;
		
		HttpRequest.getString('gallery.html').then((String data) {
			el = new Element.html(data);
			images = el.querySelectorAll('.gallery-thumb');
			
			images.forEach((ImageElement image) {
				image.onClick.listen((_) {
					changeGroupImage(panel.group, image);
					el.remove();
				});
			});
			document.getElementsByTagName('body')[0].append(el);
		});
	}
	
	void	_configureTemplate({
			DivElement		leftContainer
		})
	{
		_leftContainer = leftContainer;
		
		if (_background != null)
			leftContainer.style
				..backgroundImage = 'url(${_background.src})'
			;

		if (_patternName != null && _config['sets'][_patternName] != null) {
			_createPanels(_config['sets'][_patternName]);
		}
		
		window.requestAnimationFrame(_draw);
	}
	
	void	_createPanels(Map<String, dynamic> config)
	{
		List<Map<String, dynamic>>	panels;
		Panel						panel;
		Group						group;
		
		panels = config['panels'];
		
		group = new Group('red');
		
		panels.forEach((Map<String, dynamic> panelConfig) {
			panel = _addPanel(panelConfig);
			group.addPanel(panel);
		});
	}
	
	void	_draw(double time)
	{
		_panels.forEach((Panel panel) {
			panel.draw(time);
		});
		window.requestAnimationFrame(_draw);
	}

	get		scale						=> _scale;
	get		scaleDelta					=> _scaleDelta;
	get		config						=> _config;
	get		leftContainer				=> _leftContainer;
	
	set		movingPanel(movingPanel)	=> _movingPanel = movingPanel;
	
	set		movingImage(movingImage)	=> _movingImage = movingImage;
	
	set		resizingPanel(resizingPanel)	=> _resizingPanel = resizingPanel;
}