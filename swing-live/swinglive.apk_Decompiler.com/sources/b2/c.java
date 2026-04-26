package b2;

import I3.p;
import a2.EnumC0188a;
import a2.e;
import a2.f;
import java.nio.ByteBuffer;
import w3.i;
import y1.AbstractC0752b;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class c extends H0.a {

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final byte[] f3281i = new byte[1];

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public a2.d f3282j = a2.d.f2638b;

    @Override // H0.a
    public final Object l(B1.d dVar, p pVar, InterfaceC0762c interfaceC0762c) {
        ByteBuffer byteBuffer = dVar.f115a;
        B1.b bVar = dVar.f116b;
        ByteBuffer byteBufferJ = AbstractC0752b.j(byteBuffer, bVar);
        f[] fVarArr = f.f2642a;
        byte b5 = (byte) (this.f3282j.f2640a << 1);
        e[] eVarArr = e.f2641a;
        EnumC0188a[] enumC0188aArr = EnumC0188a.f2633a;
        byte[] bArr = this.f3281i;
        bArr[0] = (byte) (((byte) (b5 | ((byte) 0))) | ((byte) 112));
        int iRemaining = byteBufferJ.remaining() + bArr.length;
        byte[] bArr2 = new byte[iRemaining];
        byteBufferJ.get(bArr2, bArr.length, byteBufferJ.remaining());
        System.arraycopy(bArr, 0, bArr2, 0, bArr.length);
        Object objInvoke = pVar.invoke(new Z1.a(bArr2, bVar.f110c / ((long) 1000), iRemaining, Z1.b.f2597a), interfaceC0762c);
        return objInvoke == EnumC0789a.f6999a ? objInvoke : i.f6729a;
    }

    @Override // H0.a
    public final void a0(boolean z4) {
    }
}
