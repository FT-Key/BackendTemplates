comando para crear estructura inicial

"
mkdir -p src/{application/user/{services,use-cases},domain,infrastructure/database,interfaces/http/{routes,controllers},config}
touch index.js \
 src/domain/user.js \
 src/infrastructure/database/userRepositoryMongo.js \
 src/interfaces/http/routes/userRoutes.js \
 src/interfaces/http/controllers/userController.js \
 src/application/user/services/userService.js \
 src/application/user/use-cases/createUser.js \
 src/config/server.js
"
