package tests;

@:dce
@:build(tests.Builder.buildMain())
class Main {
    static function main() {
        final runner = Type.resolveClass("tests.Runner");
        Reflect.callMethod(runner, Reflect.field(runner, "run"), []);
    }
}