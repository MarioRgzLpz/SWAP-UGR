from locust import HttpUser, TaskSet, task, between

class P5_tuusuariougr(TaskSet):
    
    # def on_start(self):
    #     """Autenticación de usuarios al inicio de la prueba"""
    #     self.login()
    
    
    @task(1)
    def load_index(self):
        """Carga la página principal"""
        self.client.get("/index.php", verify=False)
    
    @task(2)
    def load_page(self):
        """Carga una página de contenido"""
        self.client.get("/wp-load.php", verify=False)
    
    @task(3)
    def login(self):
        """Simula el inicio de sesión de un usuario"""
        self.client.post("/wp-login.php", {"log": "testuser", "pwd": "password"}, verify=False)
        
    # def create_post(self):
    #     """Simula la creación de una nueva publicación"""
    #     self.client.post("/create_post.php", {"title": "Nuevo post", "content": "Contenido del post"}, verify=False)
    
    @task(4)
    def insert_comment(self):
        """Simula la inserción de un comentario en una publicación"""
        self.client.post("/wp-comment-post.php", {"post_id": 1, "comment": "Este es un comentario"}, verify=False)
    
    # @task(5)
    # def search(self):
    #     """Simula una consulta de búsqueda"""
    #     self.client.get("/search.php?q=locust", verify=False)
    
    # @task(6)
    # def logout(self):
    #     """Simula el cierre de sesión de un usuario"""
    #     self.client.get("/logout.php", verify=False)

class P5_usuarios(HttpUser):
    tasks = [P5_tuusuariougr]
    wait_time = between(1, 5)