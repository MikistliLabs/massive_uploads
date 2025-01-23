<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Laravel\Passport\Client;
use App\Models\User;

class AuthController extends Controller
{
    public function login(Request $request)
    {
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
                return response()->json(json_decode($response->getContent(), true));
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
            ]);
            $user = new User([
                'name' => $request->name,
                'email' => $request->email,
                'password' => bcrypt($request->password),
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
