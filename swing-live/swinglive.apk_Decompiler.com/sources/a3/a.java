package A3;

import e1.AbstractC0367g;
import java.io.Serializable;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public abstract class a implements InterfaceC0762c, d, Serializable {
    private final InterfaceC0762c completion;

    public a(InterfaceC0762c interfaceC0762c) {
        this.completion = interfaceC0762c;
    }

    public InterfaceC0762c create(InterfaceC0762c interfaceC0762c) {
        J3.i.e(interfaceC0762c, "completion");
        throw new UnsupportedOperationException("create(Continuation) has not been overridden");
    }

    @Override // A3.d
    public d getCallerFrame() {
        InterfaceC0762c interfaceC0762c = this.completion;
        if (interfaceC0762c instanceof d) {
            return (d) interfaceC0762c;
        }
        return null;
    }

    public final InterfaceC0762c getCompletion() {
        return this.completion;
    }

    public StackTraceElement getStackTraceElement() {
        int iIntValue;
        String strC;
        Method method;
        Object objInvoke;
        Method method2;
        Object objInvoke2;
        e eVar = (e) getClass().getAnnotation(e.class);
        String str = null;
        if (eVar == null || eVar.v() < 1) {
            return null;
        }
        try {
            Field declaredField = getClass().getDeclaredField("label");
            declaredField.setAccessible(true);
            Object obj = declaredField.get(this);
            Integer num = obj instanceof Integer ? (Integer) obj : null;
            iIntValue = (num != null ? num.intValue() : 0) - 1;
        } catch (Exception unused) {
            iIntValue = -1;
        }
        int i4 = iIntValue >= 0 ? eVar.l()[iIntValue] : -1;
        f fVar = g.f91b;
        f fVar2 = g.f90a;
        if (fVar == null) {
            try {
                f fVar3 = new f(Class.class.getDeclaredMethod("getModule", new Class[0]), getClass().getClassLoader().loadClass("java.lang.Module").getDeclaredMethod("getDescriptor", new Class[0]), getClass().getClassLoader().loadClass("java.lang.module.ModuleDescriptor").getDeclaredMethod("name", new Class[0]));
                g.f91b = fVar3;
                fVar = fVar3;
            } catch (Exception unused2) {
                g.f91b = fVar2;
                fVar = fVar2;
            }
        }
        if (fVar != fVar2 && (method = fVar.f87a) != null && (objInvoke = method.invoke(getClass(), new Object[0])) != null && (method2 = fVar.f88b) != null && (objInvoke2 = method2.invoke(objInvoke, new Object[0])) != null) {
            Method method3 = fVar.f89c;
            Object objInvoke3 = method3 != null ? method3.invoke(objInvoke2, new Object[0]) : null;
            if (objInvoke3 instanceof String) {
                str = (String) objInvoke3;
            }
        }
        if (str == null) {
            strC = eVar.c();
        } else {
            strC = str + '/' + eVar.c();
        }
        return new StackTraceElement(strC, eVar.m(), eVar.f(), i4);
    }

    public abstract Object invokeSuspend(Object obj);

    @Override // y3.InterfaceC0762c
    public final void resumeWith(Object obj) {
        InterfaceC0762c interfaceC0762c = this;
        while (true) {
            a aVar = (a) interfaceC0762c;
            InterfaceC0762c interfaceC0762c2 = aVar.completion;
            J3.i.b(interfaceC0762c2);
            try {
                obj = aVar.invokeSuspend(obj);
                if (obj == EnumC0789a.f6999a) {
                    return;
                }
            } catch (Throwable th) {
                obj = AbstractC0367g.h(th);
            }
            aVar.releaseIntercepted();
            if (!(interfaceC0762c2 instanceof a)) {
                interfaceC0762c2.resumeWith(obj);
                return;
            }
            interfaceC0762c = interfaceC0762c2;
        }
    }

    public String toString() {
        StringBuilder sb = new StringBuilder("Continuation at ");
        Object stackTraceElement = getStackTraceElement();
        if (stackTraceElement == null) {
            stackTraceElement = getClass().getName();
        }
        sb.append(stackTraceElement);
        return sb.toString();
    }

    public InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        J3.i.e(interfaceC0762c, "completion");
        throw new UnsupportedOperationException("create(Any?;Continuation) has not been overridden");
    }

    public void releaseIntercepted() {
    }
}
