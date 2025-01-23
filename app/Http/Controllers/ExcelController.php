<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ExcelController extends Controller
{
    /**
     * Subir y procesar el archivo Excel.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
    */
    public function uploadExcel(Request $request){
        // Validación del archivo
        $validator = Validator::make($request->all(), [
            'file' => 'required|mimes:xlsx,xls,csv|max:2048', // Valida la extención del archivo y lo limita a 2 mb
        ]);
        // dd($request, $validator, $validator->fails());
        if ($validator->fails()) {
            return response()->json([
                'message' => 'Archivo inválido o demasiado grande.'
            ], 400);
        }
        // Obtener el archivo
        $file = $request->file('file');
        // Se guarda el archivo en una ruta accesible
        $filePath = $file->storeAs('uploads', $file->getClientOriginalName(), 'local');
        // Obtene,mos la ruta absoluta del archivo
        $absolutePath = storage_path('app/' . $filePath);
        // dd($absolutePath);
        // Procesamos el archivo usando LOAD DATA LOCALE INFILE
        try {
            // Verificamos la codificación y la convertimos en caso de ser necesario
            $content = file_get_contents($absolutePath);
            $encoding = mb_detect_encoding($content, ['UTF-8', 'ISO-8859-1', 'WINDOWS-1252'], true);
            // Si la codificación del CSV es diferente procedemos a convertirlo
            if($encoding !== 'UTF-8'){
                $content = mb_convert_encoding($content, 'UTF-8', $encoding);
                file_put_contents($absolutePath, $content);
            }
            // Seteamos la configuración de la conexión
            DB::statement("SET NAMES 'utf8mb4'");
            DB::statement("SET CHARACTER SET utf8mb4");
            DB::statement("SET SESSION collation_connection = 'utf8mb4_unicode_ci'");
            $sql = "
                LOAD DATA LOCAL INFILE '".addslashes($absolutePath)."'
                INTO TABLE temporal_person
                CHARACTER SET utf8mb4
                FIELDS TERMINATED BY ','
                ENCLOSED BY '\"'
                LINES TERMINATED BY '\r\n'
                IGNORE 1 LINES
                (nombre, paterno, materno, telefono, calle, numero_exterior, numero_interior, colonia, cp)
            ";
            // Ejecutar la carga del Archivo excel
            DB::statement($sql);
            // Ejecuta el SP de dispersión de datos
            DB::statement('CALL DisperseTemporalPersonData()');

            return response()->json(['message' => 'Archivo procesado correctamente.'], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error interno',
                'error' => $e->getMessage()
            ], 200);
        }
    }
}
