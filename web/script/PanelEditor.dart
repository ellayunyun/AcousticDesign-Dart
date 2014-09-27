
library PanelEditor;

import 'dart:html';
import 'dart:math' as Math;
import 'dart:convert';

part 'Editor.dart';
part 'Template.dart';
part 'BackgroundScaler.dart';
part 'Panel.dart';
part 'Group.dart';

class PanelEditor
{
    DivElement      		_container;
    ImageElement   			_backgroundImage;
    Template				_template;
	Map<String, dynamic>	_config;
    
    PanelEditor()
    {
    	HttpRequest.getString('config.json')
    		..then((String data) {
    			_config = JSON.decode(data);
    			
    			_template = new Template(this);
                _container = document.getElementById('editor');
                
                _template.showBackgroundUpload(
            		fileHandler: (InputElement fileInput) {
            			if (fileInput.files.length == 1)
            				_loadBackground(fileInput.files[0]);
            		},
            		skipHandler: () => () {}
                );
    		})
    		..catchError((error) {
    			window.alert(error);
    		})
		;
    	
    }
    
    void	_configureBackground()
    {
    	BackgroundScaler	scaler;
    	CanvasElement		canvas;
    	
    	canvas = _template.showBackgroundScaler();
    	scaler = new BackgroundScaler(
    		template: _template,
    		canvas: canvas,
    		image: _backgroundImage,
    		callback: _launchEditor
		);
    }
    
    void	_launchEditor({ double scale })
    {
    	new Editor(
    		template: _template,
			scale: scale,
			background: _backgroundImage,
			config: _config
		);
    }
    
    void    _loadBackground(File file)
    {   
        FileReader      reader;
        
        if (!file.type.startsWith('image')) {
            window.alert('Not an image');
            return ;
        }
        
        reader = new FileReader()
            ..onLoad.listen((_) {
                _backgroundImage = new ImageElement(src: reader.result);
                /*
                _configureBackground();
                
                */
                
                // skipping
				
		    	new Editor(
		    		template: _template,
					scale: 1.64506838763621,
					background: _backgroundImage,
					config: _config
				);
				
            }
        );
        
        reader.readAsDataUrl(file);
    }
    
    DivElement		get container =>		_container;
    ImageElement	get backgroundImage =>	_backgroundImage;
}