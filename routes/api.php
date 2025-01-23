<?php

use Illuminate\Http\Request;
use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/
Route::post('/login', [AuthController::class, 'login']);
Route::post('/singup', [AuthController::class, 'singup']);
Route::get('helloword', [AuthController::class, 'index']);
Route::middleware('auth:api')->get('/user', function (Request $request){
    return $request->user();
});
Route::group(['prefix'=>'upload', 'middleware' => ['auth:api']], function(){
    Route::get('helloword', [AuthController::class, 'index']);
    Route::post('logout', [AuthController::class, 'logout']);
});

