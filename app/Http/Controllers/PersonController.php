<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PersonController extends Controller
{
    public function getPeople(Request $request){
        // Validar los parámetros de paginación
        $request->validate([
            'page' => 'required|integer|min:1',
            'pageSize' => 'required|integer|min:1|max:100',
        ]);

        $page = $request->input('page', 1);
        $pageSize = $request->input('pageSize', 100);
        $startIndex = ($page - 1) * $pageSize;

        try {
            // Llamar al procedimiento almacenado
            $results = DB::select('CALL SP_GetPeople(?, ?)', [$startIndex, $pageSize]);
            // Convertir los resultados a un arreglo asociativo
            $data = json_decode(json_encode($results), true); // Convertir el primer conjunto de resultados a arreglo
            $totalRecords = count($results);

            return response()->json([
                'data' => $data,
                'totalRecords' => $totalRecords,
                'page' => $page,
                'pageSize' => $pageSize,
            ]);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function getPersonDetails($id)
    {
        try {
            // Obtener los detalles de la persona (teléfonos y direcciones)
            $phones = DB::table('phone')
                ->where('person_id', $id)
                ->get();

            $addresses = DB::table('address')
                ->where('person_id', $id)
                ->get();

            return response()->json([
                'phones' => $phones,
                'addresses' => $addresses,
            ]);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}

