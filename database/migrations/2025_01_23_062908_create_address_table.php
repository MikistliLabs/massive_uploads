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
        Schema::create('address', function (Blueprint $table) {
            $table->increments('id');
            $table->string('calle')->nullable();
            $table->string('numero_exterior', 10)->nullable();
            $table->string('numero_interior', 10)->nullable();
            $table->string('colonia')->nullable();
            $table->string('cp', 10)->nullable();
            $table->unsignedInteger('person_id');
            $table->foreign('person_id')->references('id')->on('person')->onDelete('cascade');
        });
        // Añadir el índice a la tabla phone
        Schema::table('address', function (Blueprint $table) {
            $table->index(['calle', 'numero_exterior', 'numero_interior', 'colonia', 'cp', 'person_id'], 'idx_address_person');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('address');
        // Eliminar el índice de la tabla person
        Schema::table('address', function (Blueprint $table) {
            $table->dropIndex('idx_address_person');
        });
    }
};
