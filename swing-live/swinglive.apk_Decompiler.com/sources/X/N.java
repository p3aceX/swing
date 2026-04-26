package X;

import android.media.Image;
import android.util.Base64;
import com.google.android.gms.common.api.internal.InterfaceC0271t;
import com.google.android.gms.common.internal.InterfaceC0295s;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.crypto.tink.shaded.protobuf.S;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.nio.ByteBuffer;
import java.security.KeyFactory;
import java.security.KeyPairGenerator;
import java.security.MessageDigest;
import java.security.Provider;
import java.security.Signature;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import javax.crypto.Cipher;
import javax.crypto.KeyAgreement;
import javax.crypto.Mac;
import q3.C0637b;

/* JADX INFO: loaded from: classes.dex */
public final class N implements InterfaceC0271t, InterfaceC0295s, b4.a, j.o {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f2308a;

    public /* synthetic */ N(int i4) {
        this.f2308a = i4;
    }

    public static g2.g i(int i4) throws IOException {
        Object next;
        B3.b bVar = g2.g.f4353x;
        bVar.getClass();
        J3.a aVar = new J3.a(bVar);
        while (true) {
            if (!aVar.hasNext()) {
                next = null;
                break;
            }
            next = aVar.next();
            if (((g2.g) next).f4354a == i4) {
                break;
            }
        }
        g2.g gVar = (g2.g) next;
        if (gVar != null) {
            return gVar;
        }
        throw new IOException(S.d(i4, "Unknown rtmp message type: "));
    }

    public static void m(Image.Plane plane, int i4, int i5, byte[] bArr, int i6, int i7) {
        ByteBuffer buffer = plane.getBuffer();
        buffer.rewind();
        int rowStride = ((plane.getRowStride() + buffer.limit()) - 1) / plane.getRowStride();
        if (rowStride == 0) {
            return;
        }
        int i8 = i4 / (i5 / rowStride);
        int rowStride2 = 0;
        for (int i9 = 0; i9 < rowStride; i9++) {
            int pixelStride = rowStride2;
            for (int i10 = 0; i10 < i8; i10++) {
                bArr[i6] = buffer.get(pixelStride);
                i6 += i7;
                pixelStride += plane.getPixelStride();
            }
            rowStride2 += plane.getRowStride();
        }
    }

    @Override // com.google.android.gms.common.internal.InterfaceC0295s
    public /* bridge */ /* synthetic */ Object b(com.google.android.gms.common.api.s sVar) {
        return null;
    }

    @Override // b4.a
    public b4.b c() {
        return d4.b.f3958a;
    }

    public List d(String str) throws ClassNotFoundException, IOException {
        switch (this.f2308a) {
            case 21:
                try {
                    return (List) new l3.N(new ByteArrayInputStream(Base64.decode(str, 0))).readObject();
                } catch (IOException | ClassNotFoundException e) {
                    throw new RuntimeException(e);
                }
            default:
                J3.i.e(str, "listString");
                Object object = new l3.N(new ByteArrayInputStream(Base64.decode(str, 0))).readObject();
                J3.i.c(object, "null cannot be cast to non-null type kotlin.collections.List<*>");
                ArrayList arrayList = new ArrayList();
                for (Object obj : (List) object) {
                    if (obj instanceof String) {
                        arrayList.add(obj);
                    }
                }
                return arrayList;
        }
    }

    public String e(List list) throws IOException {
        switch (this.f2308a) {
            case 21:
                try {
                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                    ObjectOutputStream objectOutputStream = new ObjectOutputStream(byteArrayOutputStream);
                    objectOutputStream.writeObject(list);
                    objectOutputStream.flush();
                    return Base64.encodeToString(byteArrayOutputStream.toByteArray(), 0);
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            default:
                J3.i.e(list, "list");
                ByteArrayOutputStream byteArrayOutputStream2 = new ByteArrayOutputStream();
                ObjectOutputStream objectOutputStream2 = new ObjectOutputStream(byteArrayOutputStream2);
                objectOutputStream2.writeObject(list);
                objectOutputStream2.flush();
                String strEncodeToString = Base64.encodeToString(byteArrayOutputStream2.toByteArray(), 0);
                J3.i.d(strEncodeToString, "encodeToString(...)");
                return strEncodeToString;
        }
    }

    /* JADX WARN: Code restructure failed: missing block: B:32:0x00c5, code lost:
    
        if (r14.l(r8, r0, r2, r7) != r1) goto L14;
     */
    /* JADX WARN: Removed duplicated region for block: B:21:0x0067  */
    /* JADX WARN: Removed duplicated region for block: B:35:0x00d2  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:26:0x0083 -> B:14:0x003a). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:32:0x00c5 -> B:14:0x003a). Please report as a decompilation issue!!! */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object f(e1.AbstractC0367g r10, g2.j r11, int r12, com.google.android.gms.common.internal.r r13, A3.c r14) throws java.io.IOException {
        /*
            Method dump skipped, instruction units count: 220
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: X.N.f(e1.g, g2.j, int, com.google.android.gms.common.internal.r, A3.c):java.lang.Object");
    }

    public Object g(String str, Provider provider) {
        switch (this.f2308a) {
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                return provider == null ? Cipher.getInstance(str) : Cipher.getInstance(str, provider);
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                return provider == null ? KeyAgreement.getInstance(str) : KeyAgreement.getInstance(str, provider);
            case 9:
                return provider == null ? KeyFactory.getInstance(str) : KeyFactory.getInstance(str, provider);
            case 10:
                return provider == null ? KeyPairGenerator.getInstance(str) : KeyPairGenerator.getInstance(str, provider);
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                return provider == null ? Mac.getInstance(str) : Mac.getInstance(str, provider);
            case 12:
                return provider == null ? MessageDigest.getInstance(str) : MessageDigest.getInstance(str, provider);
            default:
                return provider == null ? Signature.getInstance(str) : Signature.getInstance(str, provider);
        }
    }

    @Override // j.o
    public boolean h(j.t tVar) {
        return false;
    }

    /* JADX WARN: Removed duplicated region for block: B:8:0x001e  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object j(int r21, A3.c r22, com.google.android.gms.common.internal.r r23, e1.AbstractC0367g r24) throws java.io.IOException {
        /*
            Method dump skipped, instruction units count: 480
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: X.N.j(int, A3.c, com.google.android.gms.common.internal.r, e1.g):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:44:0x00d6  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object k(e1.AbstractC0367g r12, A3.c r13) throws java.io.IOException {
        /*
            Method dump skipped, instruction units count: 292
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: X.N.k(e1.g, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:103:0x034c  */
    /* JADX WARN: Removed duplicated region for block: B:107:0x037a  */
    /* JADX WARN: Removed duplicated region for block: B:110:0x0387  */
    /* JADX WARN: Removed duplicated region for block: B:115:0x03b0  */
    /* JADX WARN: Removed duplicated region for block: B:119:0x016f A[SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:32:0x0162  */
    /* JADX WARN: Removed duplicated region for block: B:38:0x017a  */
    /* JADX WARN: Removed duplicated region for block: B:62:0x0201  */
    /* JADX WARN: Removed duplicated region for block: B:67:0x0227  */
    /* JADX WARN: Removed duplicated region for block: B:79:0x0278  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Removed duplicated region for block: B:83:0x02a1  */
    /* JADX WARN: Removed duplicated region for block: B:86:0x02b5  */
    /* JADX WARN: Removed duplicated region for block: B:91:0x02df  */
    /* JADX WARN: Removed duplicated region for block: B:92:0x02e6  */
    /* JADX WARN: Removed duplicated region for block: B:99:0x0326  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object l(int r12, A3.c r13, com.google.android.gms.common.internal.r r14, e1.AbstractC0367g r15) throws java.io.IOException {
        /*
            Method dump skipped, instruction units count: 994
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: X.N.l(int, A3.c, com.google.android.gms.common.internal.r, e1.g):java.lang.Object");
    }

    public N(byte[] bArr, C0637b[] c0637bArr, LinkedHashSet linkedHashSet) {
        this.f2308a = 26;
        J3.i.e(c0637bArr, "hashAndSign");
    }

    public N() {
        this.f2308a = 0;
        new n.b();
        new n.e();
    }

    @Override // j.o
    public void a(j.j jVar, boolean z4) {
    }
}
