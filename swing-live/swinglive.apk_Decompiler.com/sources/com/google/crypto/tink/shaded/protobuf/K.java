package com.google.crypto.tink.shaded.protobuf;

import java.nio.charset.Charset;

/* JADX INFO: loaded from: classes.dex */
public final class K {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0313s f3739b = new C0313s(1);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Object f3740a;

    public K(C0306k c0306k) {
        AbstractC0320z.a(c0306k, "output");
        this.f3740a = c0306k;
        c0306k.f3812i = this;
    }

    public void a(int i4, AbstractC0303h abstractC0303h) throws io.ktor.utils.io.E {
        C0306k c0306k = (C0306k) this.f3740a;
        c0306k.F0(i4, 2);
        c0306k.G0(abstractC0303h.size());
        C0302g c0302g = (C0302g) abstractC0303h;
        c0306k.z0(c0302g.f3790d, c0302g.k(), c0302g.size());
    }

    public void b(int i4, Object obj, c0 c0Var) throws io.ktor.utils.io.E {
        C0306k c0306k = (C0306k) this.f3740a;
        c0306k.F0(i4, 3);
        c0Var.h((AbstractC0296a) obj, c0306k.f3812i);
        c0306k.F0(i4, 4);
    }

    public void c(int i4, Object obj, c0 c0Var) throws io.ktor.utils.io.E {
        AbstractC0296a abstractC0296a = (AbstractC0296a) obj;
        C0306k c0306k = (C0306k) this.f3740a;
        c0306k.F0(i4, 2);
        c0306k.G0(abstractC0296a.b(c0Var));
        c0Var.h(abstractC0296a, c0306k.f3812i);
    }

    public K() {
        O o4;
        try {
            o4 = (O) Class.forName("com.google.crypto.tink.shaded.protobuf.DescriptorMessageInfoFactory").getDeclaredMethod("getInstance", new Class[0]).invoke(null, new Object[0]);
        } catch (Exception unused) {
            o4 = f3739b;
        }
        O[] oArr = {C0313s.f3835b, o4};
        J j4 = new J();
        j4.f3738a = oArr;
        Charset charset = AbstractC0320z.f3839a;
        this.f3740a = j4;
    }
}
