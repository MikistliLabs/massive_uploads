<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Laravel\Passport\Client;
use App\Models\User;

class AuthController extends Controller
{
    public function login(Request $request){
        // dd($request);
        try {
            // Validar las credenciales del usuario
            $request->validate([
                'email' => 'required|email',
                'password' => 'required',
            ]);

            // Buscar el cliente de Passport
            $client = Client::where('password_client', true)->first();

            if (!$client) {
                return response()->json(['message' => 'Error en la configuración de OAuth2'], 500);
            }
            // dd($client);
            // Preparar los datos para la petición del token
            $data = [
                'grant_type' => 'password',
                'client_id' => $client->id,
                'client_secret' => $client->secret,
                'username' => $request->email,
                'password' => $request->password,
                'scope' => '',
            ];
            // Hacer la petición del token al endpoint de Passport
            $tokenRequest = Request::create('/oauth/token', 'POST', $data);
            $response = app()->handle($tokenRequest);
            // Devolver el token o un error
            if ($response->getStatusCode() === 200) {
                // Recuperamos los datos del usuario que acaba de iniciar sesion
                $user = User::where('email', $request->email)->first();
                $dataUsr = [
                    'name' => $user->name,
                    'email' => $user->email,
                    'user_type' => $user->user_type,
                ];
                return response()->json([
                    'token_data' => json_decode($response->getContent(), true),
                    'user' => $dataUsr,
                ], 200);
                // return response()->json(json_decode($response->getContent(), true));
            }
            return response()->json(['message' => 'Credenciales inválidas'], 401);
        }catch (\Exception $e) {
            // Manejar otros errores
            return response()->json([
                'message' => 'Error interno del servidor',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    public function singup(Request $request){
        try {
            $request->validate([
                'name' => 'required|string',
                'email' => 'required|string|email|unique:users',
                'password' => 'required|string|confirmed',
                'user_type' => 'required|int',
            ]);
            $user = new User([
                'name' => $request->name,
                'email' => $request->email,
                'password' => bcrypt($request->password),
                'user_type' => $request->user_type,
            ]);
            $user->save();
            return response()->json([
                'message' => 'Usuario registrado correctamente'
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'message' => 'Error de validación',
                'errors' => $e->errors()
            ],422);
        }catch(\Exception $e){
            return response()->json([
                'message' => 'Ocurrio un error inesperado',
                'error' => $e->getMessage()
            ],500);
        }
    }
    public function logout(Request $request){
        // Verificar si el usuario está autenticado
        $user = auth()->user();

        if (!$user) {
            return response()->json([
                'message' => 'Sin sesión'
            ], 200);
        }
        $request->user()->token()->revoke();
        return response()->json([
            'message' => 'Sesión termida',
        ], 200);
    }
    public function index(){
        return response()->json([
            'message' => 'accedio correctamente',
        ], 200);
    }
}
