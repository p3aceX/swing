package androidx.lifecycle;

import a0.C0185a;
import a0.InterfaceC0186b;
import android.app.Application;
import android.content.Context;
import android.os.Handler;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class ProcessLifecycleInitializer implements InterfaceC0186b {
    @Override // a0.InterfaceC0186b
    public final List a() {
        return x3.p.f6784a;
    }

    @Override // a0.InterfaceC0186b
    public final Object b(Context context) {
        J3.i.e(context, "context");
        C0185a c0185aC = C0185a.c(context);
        J3.i.d(c0185aC, "getInstance(context)");
        if (!c0185aC.f2631b.contains(ProcessLifecycleInitializer.class)) {
            throw new IllegalStateException("ProcessLifecycleInitializer cannot be initialized lazily.\n               Please ensure that you have:\n               <meta-data\n                   android:name='androidx.lifecycle.ProcessLifecycleInitializer'\n                   android:value='androidx.startup' />\n               under InitializationProvider in your AndroidManifest.xml");
        }
        if (!k.f3072a.getAndSet(true)) {
            Context applicationContext = context.getApplicationContext();
            J3.i.c(applicationContext, "null cannot be cast to non-null type android.app.Application");
            ((Application) applicationContext).registerActivityLifecycleCallbacks(new j());
        }
        y yVar = y.f3099o;
        yVar.getClass();
        yVar.e = new Handler();
        yVar.f3104f.e(EnumC0221g.ON_CREATE);
        Context applicationContext2 = context.getApplicationContext();
        J3.i.c(applicationContext2, "null cannot be cast to non-null type android.app.Application");
        ((Application) applicationContext2).registerActivityLifecycleCallbacks(new x(yVar));
        return yVar;
    }
}
