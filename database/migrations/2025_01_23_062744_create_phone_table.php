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
        Schema::create('phone', function (Blueprint $table) {
            $table->increments('id');
            $table->string('phone', 10);
            $table->unsignedInteger('person_id');
            $table->foreign('person_id')->references('id')->on('person')->onDelete('cascade');
        });
        // Añadir el índice a la tabla phone
        Schema::table('phone', function (Blueprint $table) {
            $table->index(['phone', 'person_id'], 'idx_phone_person');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('phone');
        // Eliminar el índice de la tabla phone
        Schema::table('phone', function (Blueprint $table) {
            $table->dropIndex('idx_phone_person');
        });
    }
};
