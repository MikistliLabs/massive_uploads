<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('person', function (Blueprint $table) {
            $table->increments('id');
            $table->string('nombre');
            $table->string('paterno');
            $table->string('materno');
        });
        // Añadir el índice a la tabla person
        Schema::table('person', function (Blueprint $table) {
            $table->index(['nombre', 'paterno', 'materno'], 'idx_person_name');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('person');
        // Eliminar el índice de la tabla person
        Schema::table('person', function (Blueprint $table) {
            $table->dropIndex('idx_person_name');
        });
    }
};
