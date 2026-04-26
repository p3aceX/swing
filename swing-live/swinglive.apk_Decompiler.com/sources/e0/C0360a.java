package e0;

import J3.i;
import J3.j;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import z0.C0779j;

/* JADX INFO: renamed from: e0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0360a extends j implements I3.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3973a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0779j f3974b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public /* synthetic */ C0360a(int i4, C0779j c0779j) {
        super(0);
        this.f3973a = i4;
        this.f3974b = c0779j;
    }

    @Override // I3.a
    public final Object a() throws NoSuchMethodException, ClassNotFoundException {
        switch (this.f3973a) {
            case 0:
                Class<?> clsLoadClass = ((ClassLoader) this.f3974b.f6969b).loadClass("androidx.window.extensions.WindowExtensionsProvider");
                i.d(clsLoadClass, "loader.loadClass(WindowE…XTENSIONS_PROVIDER_CLASS)");
                return clsLoadClass;
            default:
                C0779j c0779j = this.f3974b;
                Class<?> clsLoadClass2 = ((ClassLoader) c0779j.f6969b).loadClass("androidx.window.extensions.WindowExtensionsProvider");
                i.d(clsLoadClass2, "loader.loadClass(WindowE…XTENSIONS_PROVIDER_CLASS)");
                boolean z4 = false;
                Method declaredMethod = clsLoadClass2.getDeclaredMethod("getWindowExtensions", new Class[0]);
                Class<?> clsLoadClass3 = ((ClassLoader) c0779j.f6969b).loadClass("androidx.window.extensions.WindowExtensions");
                i.d(clsLoadClass3, "loader.loadClass(WindowE….WINDOW_EXTENSIONS_CLASS)");
                i.d(declaredMethod, "getWindowExtensionsMethod");
                if (declaredMethod.getReturnType().equals(clsLoadClass3) && Modifier.isPublic(declaredMethod.getModifiers())) {
                    z4 = true;
                }
                return Boolean.valueOf(z4);
        }
    }
}
