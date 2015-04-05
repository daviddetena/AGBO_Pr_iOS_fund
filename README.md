#HackerBooks

*Lector de libros en PDF para iPhone y iPad.*

La práctica consiste en una versión universal de una biblioteca de libros
en pdf, que serán mostrados en una lista. Al pulsar sobre uno, se cargarán
sus datos, donde se incluirá un botón para ver el contenido del libro en 
pdf.

**P: ¿isKindOfClass o isMemberOfClass? ¿Qué otros métodos similares hay? ¿En qué se distinguen?**

*R: isKindOfClass indica si un objeto hereda de una clase dada; isMemberOfClass indica si un objeto es una instancia de esa clase. En este caso, recogemos los datos de JSON mediante el método de instancia NSJSONSerialization JSONObjectWithData. Queremos guardar los datos en un NSArray. Lo devuelto por el método de JSON no es una instancia de NSArray, por lo que tendríamos que utilizar el isKindOfClass*<br>


**P: Al arrancar la app por primera vez, hay que guardar el JSON con los datos de los libros, así como las imágenes y los pdf. ¿Dónde guardarías estos datos?**

*R:El modelo JSON del servidor sería conveniente guardarlo en la carpeta Documents de la Sandbox, para que se incluyera en el backup de iTunes y también para prevenir de que sea eliminado por el sistema cuando la aplicación empieza a ocupar espacio y se empiezan a eliminar los ficheros de las carpetas Caché y Tmp*

**P: El ser o no favorito debe ser persistido de alguna manera cuando se cierra la app y cuando se abre. ¿Cómo harías eso? ¿Se te ocurre más de una forma de hacerlo? Explica la decisión de diseño que has tomado.**

*R: Se podría optar por distintas formas de guardar en disco: almacenar una propiedad isFavorite para cada libro en el modelo JSON con el que se actualiza la biblioteca que indique si un libro se ha guardado como favorito o no. De esta forma, al lanzar de nuevo la app se comprobaría ese valor y se añadirían a los favoritos aquellos con su propiedad isFavorite a true o 1. Otra opción sería guardar en disco sólo los favoritos, pero la descarté porque sería guardar información redundante (los datos de un libro favorito ya los tenemos en Sandbox y no sería necesario guardar de nuevo toda la información del libro favorito en cuestión). Una tercera opción pasaría por guardar las coordenadas de los libros que se marcan como favoritos (coordenadas de las secciones distintas a la primera, que es la de favoritos), para de esa forma, simplemente obteniendo los libros de esas coordenadas los añadiríamos al array de favoritos que se mostrarían en la sección primera. Me he quedado con la opción primera, aprovechando que los libros tienen una propiedad isFavorite. De esa forma, conforme vamos marcando/desmarcando como favorito un libro, lo volcamos a disco con esa propiedad a true o false, con lo que sólo nos quedaría añadirlo a nuestro array de favoritos.*

**P: Al cambiar el valor de isFavorite de un libro, la tabla debe reflejar ese hecho. ¿Cómo lo harías? ¿Cómo enviarías información del libro al controlador de tabla? ¿Se te ocurre más de una forma de hacerlo? ¿Cuál te parece mejor? Explica tu elección.**

*R: Principalmente pensé en dos opciones: mediante protocolo delegado o mediante notificaciones. Siempre que se pueda es mejor utilizar protocolo delegado que notificaciones. Las notificaciones no garantizan que siempre se reciba la información mediante la notificación.*

**P:Utilizar reloadData de UITableView. Esto hace que la tabla vuelva a pedir datos a su dataSource. ¿Es esto una aberración desde el punto de vista de rendimiento? Explica por qué no es así. ¿Hay una forma alternativa? ¿Cuándo crees que vale la pena usarlo?**

*R: El método reloadData de UITableView recarga los datos de las celdas que se ven en pantalla, que dependiendo del dispositivo serán más o menos. Conforme nos desplazamos por las celdas arriba o abajo se obtienen únicamente los datos que hay en pantalla. Por tanto, no es una aberración. Debería ser utilizado cuando se sabe que ha cambiado el modelo, para que lo que se muestre en pantalla refleje los datos actualizados del mismo.*

**P: Estando en el SimplePDFViewController, cuando el usuario cambie en la tabla el libro seleccionado, el pdf mostrado debe de actualizarse. ¿Cómo lo harías?**

*R: Si la tabla no tiene delegado asignado, lo haría definiendo un protocolo en la tabla e indicando que el delegado de la tabla sea el controlador que muestra el pdf. Así, este implementaría un método del protocolo de la tabla con el que se le pasaría el libro seleccionado. El controlador de pdf no tendría más que actualizar su modelo y hacer que el navegador muestre el pdf del nuevo libro seleccionado en la tabla. En nuestro caso, dado que la tabla ya tiene un delegado (el BookViewController, utilizado para la vista en split en iPad y la tabla es delegada de sí misma en iPhone), he recurrido a notificaciones. El controlador se suscribe a las notificaciones, la tabla manda una notificación cuando pulsa en una celda (didSelectRowAtIndexPath) con el libro pulsado, y el controlador de pdf al recibir la notificación, extrae de ella el libro seleccionado y actualiza su modelo con ese nuevo libro. A continuación carga el nuevo pdf.*

