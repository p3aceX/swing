package O;

import java.lang.reflect.InvocationTargetException;

/* JADX INFO: loaded from: classes.dex */
public final class G {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final n.k f1214b = new n.k();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ N f1215a;

    public G(N n4) {
        this.f1215a = n4;
    }

    public static Class b(ClassLoader classLoader, String str) throws ClassNotFoundException {
        n.k kVar = f1214b;
        n.k kVar2 = (n.k) kVar.getOrDefault(classLoader, null);
        if (kVar2 == null) {
            kVar2 = new n.k();
            kVar.put(classLoader, kVar2);
        }
        Class cls = (Class) kVar2.getOrDefault(str, null);
        if (cls != null) {
            return cls;
        }
        Class<?> cls2 = Class.forName(str, false, classLoader);
        kVar2.put(str, cls2);
        return cls2;
    }

    public static Class c(ClassLoader classLoader, String str) {
        try {
            return b(classLoader, str);
        } catch (ClassCastException e) {
            throw new A0.b(com.google.crypto.tink.shaded.protobuf.S.g("Unable to instantiate fragment ", str, ": make sure class is a valid subclass of Fragment"), e);
        } catch (ClassNotFoundException e4) {
            throw new A0.b(com.google.crypto.tink.shaded.protobuf.S.g("Unable to instantiate fragment ", str, ": make sure class name exists"), e4);
        }
    }

    public final AbstractComponentCallbacksC0109u a(String str) {
        try {
            return (AbstractComponentCallbacksC0109u) c(this.f1215a.v.f1433c.getClassLoader(), str).getConstructor(new Class[0]).newInstance(new Object[0]);
        } catch (IllegalAccessException e) {
            throw new A0.b(com.google.crypto.tink.shaded.protobuf.S.g("Unable to instantiate fragment ", str, ": make sure class name exists, is public, and has an empty constructor that is public"), e);
        } catch (InstantiationException e4) {
            throw new A0.b(com.google.crypto.tink.shaded.protobuf.S.g("Unable to instantiate fragment ", str, ": make sure class name exists, is public, and has an empty constructor that is public"), e4);
        } catch (NoSuchMethodException e5) {
            throw new A0.b(com.google.crypto.tink.shaded.protobuf.S.g("Unable to instantiate fragment ", str, ": could not find Fragment constructor"), e5);
        } catch (InvocationTargetException e6) {
            throw new A0.b(com.google.crypto.tink.shaded.protobuf.S.g("Unable to instantiate fragment ", str, ": calling Fragment constructor caused an exception"), e6);
        }
    }
}
