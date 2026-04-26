package o2;

import I3.p;
import J3.i;
import e1.k;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import n2.C0560c;
import n2.C0563f;
import n2.EnumC0562e;
import n2.EnumC0564g;
import r2.t;
import r2.u;
import x2.AbstractC0720a;
import x3.AbstractC0730j;
import y1.AbstractC0752b;
import z3.EnumC0789a;

/* JADX INFO: renamed from: o2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0581a extends AbstractC0582b {
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f5964f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final int f5965g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final int f5966h;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0581a(int i4, p2.b bVar) {
        super(i4, bVar);
        i.e(bVar, "psiManager");
        this.e = 44100;
        this.f5964f = 2;
        this.f5965g = 2;
        this.f5966h = 7;
    }

    @Override // o2.AbstractC0582b
    public final Object a(B1.d dVar, p pVar, u uVar) {
        Object objInvoke;
        ByteBuffer byteBuffer = dVar.f115a;
        B1.b bVar = dVar.f116b;
        ByteBuffer byteBufferJ = AbstractC0752b.j(byteBuffer, bVar);
        int iRemaining = byteBufferJ.remaining();
        w3.i iVar = w3.i.f6729a;
        if (iRemaining >= 0) {
            int i4 = this.f5966h;
            int i5 = iRemaining + i4;
            byte[] bArr = new byte[i5];
            AbstractC0752b.b(this.f5965g, i5, this.e, this.f5964f).get(bArr, 0, i4);
            byteBufferJ.get(bArr, i4, iRemaining);
            short sA = this.f5967a.a();
            EnumC0564g enumC0564g = EnumC0564g.f5886b;
            ByteBuffer byteBufferWrap = ByteBuffer.wrap(bArr);
            i.d(byteBufferWrap, "wrap(...)");
            ArrayList<byte[]> arrayListA = AbstractC0720a.a(this.f5970d, this.f5969c.f(k.x(new C0563f(sA, false, enumC0564g, bVar.f110c, byteBufferWrap)), false));
            ArrayList arrayList = new ArrayList(AbstractC0730j.V(arrayListA));
            for (byte[] bArr2 : arrayListA) {
                EnumC0562e enumC0562e = EnumC0562e.f5876b;
                w2.b bVar2 = w2.b.f6713b;
                arrayList.add(new C0560c(bArr2, enumC0562e, false));
            }
            if (!arrayList.isEmpty() && (objInvoke = ((t) pVar).invoke(arrayList, uVar)) == EnumC0789a.f6999a) {
                return objInvoke;
            }
        }
        return iVar;
    }

    @Override // o2.AbstractC0582b
    public final void b(boolean z4) {
    }
}
