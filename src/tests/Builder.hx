package tests;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
using Lambda;

private typedef Unit = {
    cls:ClassType,
    func:ClassField,
    isStatic:Bool,
}

class Builder {

    // This is the first function called. This is invoked by a build macro when compiled with `--main tests.Main`.
    // I find this to be more convenient than requiring the user to add `--macro tests.Builder.buildRunner()`
    public static function buildMain() {
        buildRunner();
        return Context.getBuildFields();
    }

    public static function buildRunner() {
        var inited = false;

        Context.onAfterTyping(modules -> {

            // TODO: this won't work well with macros from other libs, how do i detect the end of typing while still being able to define the runner?
            if (inited) {
                return;
            }
            inited = true;

            final units = modules.flatMap(processModule);
            Context.defineType(mkTestRunner(units));
        });
    }

    static function mkTestRunner(funcs:Array<Unit>) {
        final exprs = funcs.map(mkRunnerExpr);
        final runner = macro class Runner {
            public static function run() {
                $b{exprs};
            }
        };
        runner.meta = [{name: ":keep", pos: Context.currentPos()}];
        runner.pack = ["tests"];
        return runner;
    }

    static function qualifiedTypeName(u:Unit) {
        final names = u.cls.module.split(".");
        if (names.length != 0 && names[names.length-1] != u.cls.name)
            names.push(u.cls.name);
        return names;
    }

    static function mkRunnerExpr(u:Unit) {

        if (!u.isStatic) {
            // TODO: Is there a good way to implement method tests?
            Context.warning("Test functions must be static.", u.func.pos);
            return null;
        }

        return macro @:privateAccess $p{ qualifiedTypeName(u).concat([u.func.name]) }();
    }

    static function processModule(module:ModuleType):Array<Unit> {
        
        var funcs = [];
        var statics = [];

        switch (module) {
            case TClassDecl(_.get() => cls):

                funcs = cls.fields.get().filter(isTestFunction).map(f -> {cls: cls, func: f, isStatic: false});
                statics = cls.statics.get().filter(isTestFunction).map(f -> {cls: cls, func: f, isStatic: true});
                return funcs.concat(statics);
            default:
        }

        return [];
    }

    static function isTestFunction(field) {
        return field.meta.has(":test");
    }
}