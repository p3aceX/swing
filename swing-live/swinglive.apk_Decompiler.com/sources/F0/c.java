package f0;

import J3.i;
import J3.s;
import J3.u;
import a.AbstractC0184a;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class c implements InvocationHandler {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final J3.e f4269a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final k0.b f4270b;

    public c(J3.e eVar, k0.b bVar) {
        this.f4269a = eVar;
        this.f4270b = bVar;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference fix 'apply assigned field type' failed
    java.lang.UnsupportedOperationException: ArgType.getObject(), call class: class jadx.core.dex.instructions.args.ArgType$UnknownArg
    	at jadx.core.dex.instructions.args.ArgType.getObject(ArgType.java:593)
    	at jadx.core.dex.attributes.nodes.ClassTypeVarsAttr.getTypeVarsMapFor(ClassTypeVarsAttr.java:35)
    	at jadx.core.dex.nodes.utils.TypeUtils.replaceClassGenerics(TypeUtils.java:177)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.insertExplicitUseCast(FixTypesVisitor.java:397)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.tryFieldTypeWithNewCasts(FixTypesVisitor.java:359)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.applyFieldType(FixTypesVisitor.java:309)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.visit(FixTypesVisitor.java:94)
     */
    @Override // java.lang.reflect.InvocationHandler
    public final Object invoke(Object obj, Method method, Object[] objArr) {
        boolean zIsInstance;
        String strB;
        i.e(obj, "obj");
        i.e(method, "method");
        boolean zA = i.a(method.getName(), "accept");
        k0.b bVar = this.f4270b;
        strB = null;
        strB = null;
        strB = null;
        String strB2 = null;
        if (!zA || objArr == null || objArr.length != 1) {
            if ((i.a(method.getName(), "equals") && method.getReturnType().equals(Boolean.TYPE) && objArr != null && objArr.length == 1) == true) {
                return Boolean.valueOf(obj == (objArr != null ? objArr[0] : null));
            }
            if ((i.a(method.getName(), "hashCode") && method.getReturnType().equals(Integer.TYPE) && objArr == null) == true) {
                return Integer.valueOf(bVar.hashCode());
            }
            if (i.a(method.getName(), "toString") && method.getReturnType().equals(String.class) && objArr == null) {
                return bVar.toString();
            }
            throw new UnsupportedOperationException("Unexpected method call object:" + obj + ", method: " + method + ", args: " + objArr);
        }
        Object obj2 = objArr[0];
        Class cls = this.f4269a.f823a;
        i.e(cls, "jClass");
        Map map = J3.e.f822b;
        i.c(map, "null cannot be cast to non-null type kotlin.collections.Map<K of kotlin.collections.MapsKt__MapsKt.get, V of kotlin.collections.MapsKt__MapsKt.get>");
        Integer num = (Integer) map.get(cls);
        if (num != null) {
            zIsInstance = u.c(num.intValue(), obj2);
        } else {
            zIsInstance = (cls.isPrimitive() ? AbstractC0184a.J(s.a(cls)) : cls).isInstance(obj2);
        }
        if (zIsInstance) {
            i.c(obj2, "null cannot be cast to non-null type T of kotlin.reflect.KClasses.cast");
            bVar.invoke(obj2);
            return w3.i.f6729a;
        }
        StringBuilder sb = new StringBuilder("Value cannot be cast to ");
        if (!cls.isAnonymousClass() && !cls.isLocalClass()) {
            if (cls.isArray()) {
                Class<?> componentType = cls.getComponentType();
                if (componentType.isPrimitive() && (strB = u.b(componentType.getName())) != null) {
                    strB2 = strB.concat("Array");
                }
                if (strB2 == null) {
                    strB2 = "kotlin.Array";
                }
            } else {
                strB2 = u.b(cls.getName());
                if (strB2 == null) {
                    strB2 = cls.getCanonicalName();
                }
            }
        }
        sb.append(strB2);
        throw new ClassCastException(sb.toString());
    }
}
