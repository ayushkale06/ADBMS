import os
from flask import Flask
from dotenv import load_dotenv

load_dotenv()

def create_app():
    app = Flask(__name__)

    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'super-secret-key-12345')
    app.config['MAX_CONTENT_LENGTH'] = int(os.getenv('MAX_CONTENT_LENGTH', 5 * 1024 * 1024))
    app.config['UPLOAD_FOLDER'] = os.path.join(app.root_path, 'static', 'uploads', 'resumes')

    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

    from app.routes.auth_routes import auth_bp
    from app.routes.main_routes import main_bp
    from app.routes.internship_routes import internship_bp
    from app.routes.student_routes import student_bp
    from app.routes.faculty_routes import faculty_bp
    from app.routes.admin_routes import admin_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(main_bp)
    app.register_blueprint(internship_bp)
    app.register_blueprint(student_bp)
    app.register_blueprint(faculty_bp)
    app.register_blueprint(admin_bp)

    @app.context_processor
    def inject_user_context():
        from flask import session
        return {
            'current_user_id': session.get('user_id'),
            'current_email': session.get('email'),
            'current_role': session.get('role'),
            'current_name': session.get('name'),
            'current_role_id': session.get('role_id')
        }

    return app
