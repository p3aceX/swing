package com.google.firebase;

import Q3.A;
import androidx.annotation.Keep;
import com.google.firebase.components.ComponentRegistrar;
import g1.g;
import h1.InterfaceC0411a;
import h1.b;
import h1.c;
import h1.d;
import io.flutter.plugin.platform.f;
import java.util.List;
import java.util.concurrent.Executor;
import l1.C0522a;
import l1.j;
import l1.r;
import x3.AbstractC0729i;

/* JADX INFO: loaded from: classes.dex */
@Keep
public final class FirebaseCommonKtxRegistrar implements ComponentRegistrar {
    @Override // com.google.firebase.components.ComponentRegistrar
    public List<C0522a> getComponents() {
        f fVarA = C0522a.a(new r(InterfaceC0411a.class, A.class));
        fVarA.a(new j(new r(InterfaceC0411a.class, Executor.class), 1, 0));
        fVarA.f4629d = g.f4314b;
        C0522a c0522aB = fVarA.b();
        f fVarA2 = C0522a.a(new r(c.class, A.class));
        fVarA2.a(new j(new r(c.class, Executor.class), 1, 0));
        fVarA2.f4629d = g.f4315c;
        C0522a c0522aB2 = fVarA2.b();
        f fVarA3 = C0522a.a(new r(b.class, A.class));
        fVarA3.a(new j(new r(b.class, Executor.class), 1, 0));
        fVarA3.f4629d = g.f4316d;
        C0522a c0522aB3 = fVarA3.b();
        f fVarA4 = C0522a.a(new r(d.class, A.class));
        fVarA4.a(new j(new r(d.class, Executor.class), 1, 0));
        fVarA4.f4629d = g.e;
        return AbstractC0729i.T(c0522aB, c0522aB2, c0522aB3, fVarA4.b());
    }
}
