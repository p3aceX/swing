package i0;

import android.app.Activity;
import android.content.Context;
import androidx.window.extensions.WindowExtensionsProvider;
import androidx.window.extensions.layout.WindowLayoutComponent;
import e0.C0360a;
import e1.AbstractC0367g;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ClassLoader f4470a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final B.k f4471b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0779j f4472c;

    public e(ClassLoader classLoader, B.k kVar) {
        this.f4470a = classLoader;
        this.f4471b = kVar;
        this.f4472c = new C0779j(classLoader, 23);
    }

    public final WindowLayoutComponent a() {
        C0779j c0779j = this.f4472c;
        c0779j.getClass();
        boolean zB = false;
        try {
            new C0360a(0, c0779j).a();
            if (AbstractC0367g.O("WindowExtensionsProvider#getWindowExtensions is not valid", new C0360a(1, c0779j)) && AbstractC0367g.O("WindowExtensions#getWindowLayoutComponent is not valid", new d(this, 3)) && AbstractC0367g.O("FoldingFeature class is not valid", new d(this, 0))) {
                int iA = f0.e.a();
                if (iA == 1) {
                    zB = b();
                } else if (2 <= iA && iA <= Integer.MAX_VALUE && b()) {
                    if (AbstractC0367g.O("WindowLayoutComponent#addWindowLayoutInfoListener(" + Context.class.getName() + ", androidx.window.extensions.core.util.function.Consumer) is not valid", new d(this, 2))) {
                        zB = true;
                    }
                }
            }
        } catch (ClassNotFoundException | NoClassDefFoundError unused) {
        }
        if (!zB) {
            return null;
        }
        try {
            return WindowExtensionsProvider.getWindowExtensions().getWindowLayoutComponent();
        } catch (UnsupportedOperationException unused2) {
            return null;
        }
    }

    public final boolean b() {
        return AbstractC0367g.O("WindowLayoutComponent#addWindowLayoutInfoListener(" + Activity.class.getName() + ", java.util.function.Consumer) is not valid", new d(this, 1));
    }
}
