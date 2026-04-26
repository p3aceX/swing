package io.ktor.network.sockets;

import Q3.O;
import e1.AbstractC0367g;
import io.ktor.utils.io.C0449m;
import io.ktor.utils.io.J;
import io.ktor.utils.io.L;
import java.nio.ByteBuffer;
import java.nio.channels.ReadableByteChannel;
import java.nio.channels.WritableByteChannel;
import java.nio.channels.spi.AbstractSelectableChannel;
import v3.C0695a;

/* JADX INFO: loaded from: classes.dex */
public abstract class w extends A {

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final n3.e f4939p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final C0695a f4940q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final F f4941r;

    public w(AbstractSelectableChannel abstractSelectableChannel, n3.e eVar, C0695a c0695a, F f4) {
        J3.i.e(eVar, "selector");
        this.f4939p = eVar;
        this.f4940q = c0695a;
        this.f4941r = f4;
    }

    @Override // io.ktor.network.sockets.A
    public final Throwable f() {
        n3.e eVar = this.f4939p;
        try {
            r().close();
            super.close();
            eVar.i(this);
            return null;
        } catch (Throwable th) {
            eVar.i(this);
            return th;
        }
    }

    @Override // io.ktor.network.sockets.A
    public final L g(C0449m c0449m) {
        n3.e eVar = this.f4939p;
        C0695a c0695a = this.f4940q;
        if (c0695a == null) {
            ReadableByteChannel readableByteChannel = (ReadableByteChannel) r();
            J3.i.e(readableByteChannel, "nioChannel");
            J3.i.e(eVar, "selector");
            X3.e eVar2 = O.f1596a;
            X3.d dVar = X3.d.f2437c;
            Q3.C c5 = new Q3.C("cio-from-nio-reader");
            dVar.getClass();
            return io.ktor.utils.io.z.k(this, AbstractC0367g.A(dVar, c5), c0449m, new C0431c(this, this.f4941r, c0449m, readableByteChannel, eVar, null));
        }
        ReadableByteChannel readableByteChannel2 = (ReadableByteChannel) r();
        J3.i.e(readableByteChannel2, "nioChannel");
        J3.i.e(eVar, "selector");
        ByteBuffer byteBuffer = (ByteBuffer) c0695a.a();
        X3.e eVar3 = O.f1596a;
        X3.d dVar2 = X3.d.f2437c;
        Q3.C c6 = new Q3.C("cio-from-nio-reader");
        dVar2.getClass();
        return io.ktor.utils.io.z.k(this, AbstractC0367g.A(dVar2, c6), c0449m, new C0433e(this.f4941r, c0449m, this, byteBuffer, c0695a, readableByteChannel2, eVar, null));
    }

    @Override // io.ktor.network.sockets.A
    public final J h(C0449m c0449m) {
        WritableByteChannel writableByteChannel = (WritableByteChannel) r();
        J3.i.e(writableByteChannel, "nioChannel");
        n3.e eVar = this.f4939p;
        J3.i.e(eVar, "selector");
        X3.e eVar2 = O.f1596a;
        X3.d dVar = X3.d.f2437c;
        Q3.C c5 = new Q3.C("cio-to-nio-writer");
        dVar.getClass();
        return io.ktor.utils.io.z.h(this, AbstractC0367g.A(dVar, c5), c0449m, new i(this, this.f4941r, c0449m, eVar, writableByteChannel, null));
    }
}
