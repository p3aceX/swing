package s2;

import com.google.crypto.tink.shaded.protobuf.S;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import o3.C0592H;
import t2.EnumC0679d;
import y1.AbstractC0752b;

/* JADX INFO: renamed from: s2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0664a extends Q.b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public EnumC0679d f6478b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public EnumC0679d f6479c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f6480d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f6481f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public AbstractC0664a(EnumC0679d enumC0679d, int i4) {
        super(3);
        EnumC0679d enumC0679d2 = EnumC0679d.f6579r;
        this.f6478b = enumC0679d;
        this.f6479c = enumC0679d2;
        this.f6480d = 0;
        this.e = 0;
        this.f6481f = 0;
    }

    public final void k(ByteArrayInputStream byteArrayInputStream) {
        int iH = AbstractC0752b.h(byteArrayInputStream);
        c.f6489b.getClass();
        if (C0592H.d((iH >>> 31) & 1) != c.f6490c) {
            throw new IOException("error, parsing data packet as control packet");
        }
        EnumC0679d.f6570b.getClass();
        this.f6478b = C0592H.e((iH >>> 16) & 255);
        int i4 = iH & 65535;
        if (i4 != 0) {
            throw new IOException(S.d(i4, "unknown subtype: "));
        }
        this.f6479c = EnumC0679d.f6579r;
        this.f6480d = AbstractC0752b.h(byteArrayInputStream);
        this.e = AbstractC0752b.h(byteArrayInputStream);
        this.f6481f = AbstractC0752b.h(byteArrayInputStream);
    }

    public String toString() {
        EnumC0679d enumC0679d = this.f6478b;
        EnumC0679d enumC0679d2 = this.f6479c;
        int i4 = this.f6480d;
        int i5 = this.e;
        int i6 = this.f6481f;
        StringBuilder sb = new StringBuilder("ControlPacket(controlType=");
        sb.append(enumC0679d);
        sb.append(", subtype=");
        sb.append(enumC0679d2);
        sb.append(", typeSpecificInformation=");
        sb.append(i4);
        sb.append(", ts=");
        sb.append(i5);
        sb.append(", socketId=");
        return B1.a.n(sb, i6, ")");
    }
}
