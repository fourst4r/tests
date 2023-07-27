package tests;

import haxe.Exception;

class Assertion extends Exception {
    public function new(message:String) {
        super(message);
    }
}