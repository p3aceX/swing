package t2;

import s2.AbstractC0664a;

/* JADX INFO: renamed from: t2.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0680e extends AbstractC0664a {

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public int f6583g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public int f6584h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public int f6585i;

    @Override // s2.AbstractC0664a
    public final String toString() {
        int i4 = this.f6583g;
        int i5 = this.f6584h;
        int i6 = this.f6585i;
        StringBuilder sb = new StringBuilder("DropReq(messageNumber=");
        sb.append(i4);
        sb.append(", firstPacketSequenceNumber=");
        sb.append(i5);
        sb.append(", lastPacketSequenceNumber=");
        return B1.a.n(sb, i6, ")");
    }
}
