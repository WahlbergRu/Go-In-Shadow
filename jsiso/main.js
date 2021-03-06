require([
            'jsiso/canvas/Control',
            'jsiso/canvas/Input',
            'jsiso/img/load',
            'jsiso/json/load',
            'jsiso/tile/Field',
            'jsiso/pathfind/pathfind',
            'jsiso/particles/EffectLoader',
            'jsiso/utils',
            'requirejs/domReady!'
        ],
        function(CanvasControl, CanvasInput, imgLoader, jsonLoader, TileField, pathfind, EffectLoader, utils) {
            // -- FPS --------------------------------
            window.requestAnimFrame = (function() {
                return window.requestAnimationFrame ||
                        window.webkitRequestAnimationFrame  ||
                        window.mozRequestAnimationFrame     ||
                        window.oRequestAnimationFrame       ||
                        window.msRequestAnimationFrame      ||
                        function(callback, element) {
                            window.setTimeout(callback, 1000 / 60);
                        };
            })();
            // ---------------------------------------

            // Editor Globals ------------------------

            var tileSelection = {};

            // ---------------------------------------

            var gameScheme = {
                tileHeight: 43,//30 градусов, отношение высоты к ширине
                tileWidth: 100,

                map: 'mapSmall.json',
                imageFiles: 'imageFiles.json',
            };

            //TODO: сделать дравинг в зависимости от размера экрана

            function launch() {
                jsonLoader([gameScheme.map, gameScheme.imageFiles]).then(function(jsonResponse) {
                    imgLoader([{graphics: jsonResponse[1].images}]).then(function(imgResponse) {
                        var game = new main(0, 0, 20, 20);  // X & Y drawing position, and tile span to draw - малая карта
                        // var game = new main(45, 45, 45, 45);// X & Y drawing position, and tile span to draw - большая карта
                        game.init([{
                            Title: "Graphics",
                            layout: jsonResponse[0].ground,
                            graphics: imgResponse[0].files,
                            graphicsDictionary: imgResponse[0].dictionary,
                            heightMap: {
                                map: jsonResponse[0].height,
                                offset: -80,
                                heightTile: imgResponse[0].files["ground.png"]
                            },
                            tileHeight: gameScheme.tileHeight,
                            tileWidth: gameScheme.tileWidth,
                            zeroIsBlank: true
                        }]);
                        addTilesToHUD("Graphics", imgResponse[0].dictionary, 1);
                    });
                });
            }

            function tileChoice(layer, tile) {
                tileSelection.title = layer;
                tileSelection.value = tile;
            }

            //Функция добавления на лаяут других объктов
            function addTilesToHUD(layer, dictionary, offset) {
                var clickTile;
                dictionary.forEach(function(tile, i) {
                    var clickTile = document.createElement("a");
                    clickTile.innerHTML += ("<img  height='50' width='50' src='../img/Grass/"  + tile +"' />");
                    document.getElementById("gameInfo").appendChild(clickTile);
                    clickTile.addEventListener("click", function(e){
                        tileChoice(layer, (i + offset))
                    });
                });
            }


            function main(x, y, xrange, yrange) {
                var mapLayers = [];
                var startY = y;
                var startX = x;
                var rangeX = xrange;
                var rangeY = yrange;
                var defaultRangeY = rangeY;

                var context = CanvasControl.create("canavas", 920, 600, {
                    background: "#000022",
                    display: "block",
                    marginLeft: "auto",
                    marginRight: "auto"
                });
                CanvasControl.fullScreen();

                var input = new CanvasInput(document, CanvasControl());

                input.mouse_action(function(coords) {
                    mapLayers.map(function(layer) {
//                                console.log(layer.getHeightMapTile());
                        tile_coordinates = layer.applyMouseFocus(coords.x, coords.y); // Get the current mouse location from X & Y Coords
                        console.log(coords);
                        //layer.setHeightmapTile(tile_coordinates.x, tile_coordinates.y, layer.getHeightMapTile(tile_coordinates.x, tile_coordinates.y) + 1); // Increase heightmap tile
                        layer.setTile(tile_coordinates.x, tile_coordinates.y, tileSelection.value); // Force the chaning of tile graphic
                    });
                });

                input.mouse_move(function(coords) {
                    mapLayers.map(function(layer) {
                        tile_coordinates = layer.applyMouseFocus(coords.x, coords.y); // Apply mouse rollover via mouse location X & Y
                    });
                });


                input.keyboard(function(keyCode, pressed, e) {
                    //Светить в консоли кейкод
                    console.log(keyCode);
                    switch(keyCode) {
                        case 65:
                            //a - отдалить
                            mapLayers.map(function(layer) {
                                if (startY + rangeY + 1 < mapLayers[0].getLayout().length) {
                                    layer.setZoom("out");
                                    layer.align("h-center", CanvasControl().width, xrange, -60);
                                    layer.align("v-center", CanvasControl().height,  yrange, 240);
                                    rangeX +=  1;
                                    rangeY +=  1
                                }
                            });
                            break;
                        case 83:
                            //s - приблизить
                            mapLayers.map(function(layer) {
                                if (rangeY - 1 > defaultRangeY - 1) {
                                    layer.setZoom("in");
                                    layer.align("h-center", CanvasControl().width, xrange, -60);
                                    layer.align("v-center", CanvasControl().height,  yrange, 240);
                                    rangeX -=  1;
                                    rangeY -=  1
                                }
                            });
                            break;
                        case 49:
                            // 1 - жми АДЫН
                            mapLayers.map(function(layer) {
                                layer.toggleGraphicsHide(true);
                                layer.toggleHeightShadow(true);
                            });
                            break;
                        case 50:
                            // 2 - жми два
                            mapLayers.map(function(layer) {
                                layer.toggleGraphicsHide(false);
                                layer.toggleHeightShadow(false);
                            });
                            break;
                        case 66:
                            if (pressed && document.getElementById('gameInfo').style.display !== 'none') {
                                document.getElementById('gameInfo').style.display = 'none';
                            } else if (pressed){
                                document.getElementById('gameInfo').style.display = 'block';
                            }
                            break;
                        case 89:
                            //Поворот Y, U
                            if (pressed) {
                                mapLayers.map(function(layer) {
                                    layer.rotate("left");
                                });
                            }
                            break;
                        case 85:
                            //Поворот Y, U
                            if (pressed) {
                                mapLayers.map(function(layer) {
                                    layer.rotate("right");
                                });
                            }
                            break;
                        case 75:
                            //save на кнопку, пока что-почему-то не работает, но метод лучше оставить. Вдруг пригодится)))
                            //в нём чувствуется какая-то будущее нужда на ровне с вебсокетом
                            var XML = new XMLPopulate();
                            XML.saveMap(44, mapLayers[0].getLayout(), mapLayers[0].getHeightLayout(), null);
                            break;
                        case 39:
                            //down  - X--
                            //left  - Y++
                            //up    - Y--
                            //right - X++
                            if (pressed) {
                                mapLayers.map(function(layer) {
                                    console.log(layer);
                                    layer.move('down', gameScheme.tileHeight);
                                    layer.move('left', gameScheme.tileHeight);
                                });
                                startX --;
                                startY ++;
                            }
                            break;
                        case 38:
                            if (pressed) {
                                mapLayers.map(function(layer) {
                                    layer.move('down', gameScheme.tileHeight);
                                    layer.move('up', gameScheme.tileHeight);
                                });
                                startX --;
                                startY --;
                            }
                            break;
                        case 40:
                            if (pressed) {
                                mapLayers.map(function(layer) {
                                    layer.move("right", gameScheme.tileHeight);
                                    layer.move("left", gameScheme.tileHeight);
                                });
                                startX ++;
                                startY ++;
                            }
                            break;
                        case 37:
                            if (pressed) {
                                mapLayers.map(function(layer) {
                                    layer.move("up",gameScheme.tileHeight);
                                    layer.move("right",gameScheme.tileHeight);
                                });
                                startX ++;
                                startY --;
                            }
                            break;
                    }
                });


                function draw() {
                    context.clearRect(0, 0, CanvasControl().width, CanvasControl().height);
                    for(i = startY; i < startY + rangeY; i++) {
                        for(j = startX; j < startX + rangeX; j++) {
                            mapLayers.map(function(layer) {
                                layer.draw(i,j);
                            });
                        }
                    }
                    requestAnimFrame(draw);
                }

                return {
                    init: function(layers) {
                        for (var i = 0; i < 0 + layers.length; i++) {
                            mapLayers[i] = new TileField(context, CanvasControl().height, CanvasControl().width);
                            mapLayers[i].setup(layers[i]);
                            mapLayers[i].align("h-center", CanvasControl().width, xrange + startX, 0);
                            mapLayers[i].align("v-center", CanvasControl().height, yrange + startY, (yrange + startY));
                            mapLayers[i].setZoom("in");
                        };
                        draw();
                    }
                }

            }

            launch();

        });