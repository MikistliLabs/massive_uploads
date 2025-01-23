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
        Schema::create('temporal_person', function (Blueprint $table) {
            $table->string('nombre')->nullable();
            $table->string('paterno')->nullable();
            $table->string('materno')->nullable();
            $table->string('telefono')->nullable();
            $table->string('calle')->nullable();
            $table->string('numero_exterior', 10)->nullable();
            $table->string('numero_interior', 10)->nullable();
            $table->string('colonia')->nullable();
            $table->string('cp', 10)->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('temporal_person');
    }
};
