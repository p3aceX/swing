package D0;

import E0.f;
import E0.g;
import E0.h;
import K.k;
import M0.A;
import M0.B;
import M0.C;
import M0.C0066b;
import M0.C0070f;
import M0.C0071g;
import M0.C0073i;
import M0.C0074j;
import M0.C0075k;
import M0.C0077m;
import M0.C0086w;
import M0.C0087x;
import M0.C0088y;
import M0.C0089z;
import M0.D;
import M0.E;
import M0.EnumC0067c;
import M0.F;
import M0.H;
import M0.I;
import M0.J;
import M0.K;
import M0.L;
import M0.M;
import M0.N;
import M0.O;
import M0.P;
import M0.Q;
import M0.T;
import M0.U;
import M0.V;
import M0.c0;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.android.gms.fido.common.Transport;
import com.google.crypto.tink.shaded.protobuf.S;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class c implements Parcelable.Creator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f136a;

    public /* synthetic */ c(int i4) {
        this.f136a = i4;
    }

    @Override // android.os.Parcelable.Creator
    public final Object createFromParcel(Parcel parcel) {
        switch (this.f136a) {
            case 0:
                int iI0 = H0.a.i0(parcel);
                int iU = 0;
                a aVar = null;
                while (parcel.dataPosition() < iI0) {
                    int i4 = parcel.readInt();
                    char c5 = (char) i4;
                    if (c5 == 1) {
                        iU = H0.a.U(i4, parcel);
                    } else if (c5 != 2) {
                        H0.a.e0(i4, parcel);
                    } else {
                        aVar = (a) H0.a.o(parcel, i4, a.CREATOR);
                    }
                }
                H0.a.y(iI0, parcel);
                return new b(iU, aVar);
            case 1:
                int iI02 = H0.a.i0(parcel);
                int iU2 = 0;
                ArrayList arrayListU = null;
                while (parcel.dataPosition() < iI02) {
                    int i5 = parcel.readInt();
                    char c6 = (char) i5;
                    if (c6 == 1) {
                        iU2 = H0.a.U(i5, parcel);
                    } else if (c6 != 2) {
                        H0.a.e0(i5, parcel);
                    } else {
                        arrayListU = H0.a.u(parcel, i5, d.CREATOR);
                    }
                }
                H0.a.y(iI02, parcel);
                return new a(iU2, arrayListU);
            case 2:
                int iI03 = H0.a.i0(parcel);
                int iU3 = 0;
                String strQ = null;
                int iU4 = 0;
                while (parcel.dataPosition() < iI03) {
                    int i6 = parcel.readInt();
                    char c7 = (char) i6;
                    if (c7 == 1) {
                        iU3 = H0.a.U(i6, parcel);
                    } else if (c7 == 2) {
                        strQ = H0.a.q(i6, parcel);
                    } else if (c7 != 3) {
                        H0.a.e0(i6, parcel);
                    } else {
                        iU4 = H0.a.U(i6, parcel);
                    }
                }
                H0.a.y(iI03, parcel);
                return new d(iU3, strQ, iU4);
            case 3:
                int iI04 = H0.a.i0(parcel);
                int iU5 = 0;
                String strQ2 = null;
                E0.a aVar2 = null;
                while (parcel.dataPosition() < iI04) {
                    int i7 = parcel.readInt();
                    char c8 = (char) i7;
                    if (c8 == 1) {
                        iU5 = H0.a.U(i7, parcel);
                    } else if (c8 == 2) {
                        strQ2 = H0.a.q(i7, parcel);
                    } else if (c8 != 3) {
                        H0.a.e0(i7, parcel);
                    } else {
                        aVar2 = (E0.a) H0.a.o(parcel, i7, E0.a.CREATOR);
                    }
                }
                H0.a.y(iI04, parcel);
                return new g(aVar2, strQ2, iU5);
            case 4:
                int iI05 = H0.a.i0(parcel);
                int iU6 = 0;
                ArrayList arrayListU2 = null;
                String strQ3 = null;
                while (parcel.dataPosition() < iI05) {
                    int i8 = parcel.readInt();
                    char c9 = (char) i8;
                    if (c9 == 1) {
                        iU6 = H0.a.U(i8, parcel);
                    } else if (c9 == 2) {
                        arrayListU2 = H0.a.u(parcel, i8, f.CREATOR);
                    } else if (c9 != 3) {
                        H0.a.e0(i8, parcel);
                    } else {
                        strQ3 = H0.a.q(i8, parcel);
                    }
                }
                H0.a.y(iI05, parcel);
                return new h(iU6, strQ3, arrayListU2);
            case 5:
                int iI06 = H0.a.i0(parcel);
                int iU7 = 0;
                String strQ4 = null;
                ArrayList arrayListU3 = null;
                while (parcel.dataPosition() < iI06) {
                    int i9 = parcel.readInt();
                    char c10 = (char) i9;
                    if (c10 == 1) {
                        iU7 = H0.a.U(i9, parcel);
                    } else if (c10 == 2) {
                        strQ4 = H0.a.q(i9, parcel);
                    } else if (c10 != 3) {
                        H0.a.e0(i9, parcel);
                    } else {
                        arrayListU3 = H0.a.u(parcel, i9, g.CREATOR);
                    }
                }
                H0.a.y(iI06, parcel);
                return new f(iU7, strQ4, arrayListU3);
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                int iI07 = H0.a.i0(parcel);
                int iU8 = 0;
                Parcel parcel2 = null;
                h hVar = null;
                while (parcel.dataPosition() < iI07) {
                    int i10 = parcel.readInt();
                    char c11 = (char) i10;
                    if (c11 == 1) {
                        iU8 = H0.a.U(i10, parcel);
                    } else if (c11 == 2) {
                        int iY = H0.a.Y(i10, parcel);
                        int iDataPosition = parcel.dataPosition();
                        if (iY == 0) {
                            parcel2 = null;
                        } else {
                            Parcel parcelObtain = Parcel.obtain();
                            parcelObtain.appendFrom(parcel, iDataPosition, iY);
                            parcel.setDataPosition(iDataPosition + iY);
                            parcel2 = parcelObtain;
                        }
                    } else if (c11 != 3) {
                        H0.a.e0(i10, parcel);
                    } else {
                        hVar = (h) H0.a.o(parcel, i10, h.CREATOR);
                    }
                }
                H0.a.y(iI07, parcel);
                return new E0.d(iU8, parcel2, hVar);
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                F.k kVar = new F.k(parcel);
                kVar.f408a = parcel.readInt();
                return kVar;
            case k.BYTES_FIELD_NUMBER /* 8 */:
                String string = parcel.readString();
                try {
                    for (Transport transport : Transport.values()) {
                        if (string.equals(transport.f3619a)) {
                            return transport;
                        }
                    }
                    if (string.equals("hybrid")) {
                        return Transport.HYBRID;
                    }
                    throw new L0.a(S.g("Transport ", string, " not supported"));
                } catch (L0.a e) {
                    throw new RuntimeException(e);
                }
            case 9:
                try {
                    return EnumC0067c.a(parcel.readString());
                } catch (C0066b e4) {
                    throw new RuntimeException(e4);
                }
            case 10:
                int iI08 = H0.a.i0(parcel);
                boolean zS = false;
                while (parcel.dataPosition() < iI08) {
                    int i11 = parcel.readInt();
                    if (((char) i11) != 1) {
                        H0.a.e0(i11, parcel);
                    } else {
                        zS = H0.a.S(i11, parcel);
                    }
                }
                H0.a.y(iI08, parcel);
                return new c0(zS);
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                int iI09 = H0.a.i0(parcel);
                long jW = 0;
                while (parcel.dataPosition() < iI09) {
                    int i12 = parcel.readInt();
                    if (((char) i12) != 1) {
                        H0.a.e0(i12, parcel);
                    } else {
                        jW = H0.a.W(i12, parcel);
                    }
                }
                H0.a.y(iI09, parcel);
                return new P(jW);
            case 12:
                int iI010 = H0.a.i0(parcel);
                boolean zS2 = false;
                while (parcel.dataPosition() < iI010) {
                    int i13 = parcel.readInt();
                    if (((char) i13) != 1) {
                        H0.a.e0(i13, parcel);
                    } else {
                        zS2 = H0.a.S(i13, parcel);
                    }
                }
                H0.a.y(iI010, parcel);
                return new Q(zS2);
            case 13:
                int iI011 = H0.a.i0(parcel);
                boolean zS3 = false;
                while (parcel.dataPosition() < iI011) {
                    int i14 = parcel.readInt();
                    if (((char) i14) != 1) {
                        H0.a.e0(i14, parcel);
                    } else {
                        zS3 = H0.a.S(i14, parcel);
                    }
                }
                H0.a.y(iI011, parcel);
                return new C0086w(zS3);
            case 14:
                int iI012 = H0.a.i0(parcel);
                String strQ5 = null;
                while (parcel.dataPosition() < iI012) {
                    int i15 = parcel.readInt();
                    if (((char) i15) != 1) {
                        H0.a.e0(i15, parcel);
                    } else {
                        strQ5 = H0.a.q(i15, parcel);
                    }
                }
                H0.a.y(iI012, parcel);
                return new M0.S(strQ5);
            case 15:
                int iI013 = H0.a.i0(parcel);
                while (true) {
                    byte[][] bArr = null;
                    while (parcel.dataPosition() < iI013) {
                        int i16 = parcel.readInt();
                        if (((char) i16) != 1) {
                            H0.a.e0(i16, parcel);
                        } else {
                            int iY2 = H0.a.Y(i16, parcel);
                            int iDataPosition2 = parcel.dataPosition();
                            if (iY2 == 0) {
                            }
                            int i17 = parcel.readInt();
                            byte[][] bArr2 = new byte[i17][];
                            for (int i18 = 0; i18 < i17; i18++) {
                                bArr2[i18] = parcel.createByteArray();
                            }
                            parcel.setDataPosition(iDataPosition2 + iY2);
                            bArr = bArr2;
                        }
                        break;
                    }
                    H0.a.y(iI013, parcel);
                    return new T(bArr);
                }
                break;
            case 16:
                int iI014 = H0.a.i0(parcel);
                C c12 = null;
                F f4 = null;
                byte[] bArrJ = null;
                ArrayList arrayListU4 = null;
                Double dT = null;
                ArrayList arrayListU5 = null;
                C0077m c0077m = null;
                Integer numV = null;
                L l2 = null;
                String strQ6 = null;
                C0070f c0070f = null;
                while (parcel.dataPosition() < iI014) {
                    int i19 = parcel.readInt();
                    switch ((char) i19) {
                        case 2:
                            c12 = (C) H0.a.o(parcel, i19, C.CREATOR);
                            break;
                        case 3:
                            f4 = (F) H0.a.o(parcel, i19, F.CREATOR);
                            break;
                        case 4:
                            bArrJ = H0.a.j(i19, parcel);
                            break;
                        case 5:
                            arrayListU4 = H0.a.u(parcel, i19, A.CREATOR);
                            break;
                        case k.STRING_SET_FIELD_NUMBER /* 6 */:
                            dT = H0.a.T(i19, parcel);
                            break;
                        case k.DOUBLE_FIELD_NUMBER /* 7 */:
                            arrayListU5 = H0.a.u(parcel, i19, C0089z.CREATOR);
                            break;
                        case k.BYTES_FIELD_NUMBER /* 8 */:
                            c0077m = (C0077m) H0.a.o(parcel, i19, C0077m.CREATOR);
                            break;
                        case '\t':
                            numV = H0.a.V(i19, parcel);
                            break;
                        case '\n':
                            l2 = (L) H0.a.o(parcel, i19, L.CREATOR);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            strQ6 = H0.a.q(i19, parcel);
                            break;
                        case '\f':
                            c0070f = (C0070f) H0.a.o(parcel, i19, C0070f.CREATOR);
                            break;
                        default:
                            H0.a.e0(i19, parcel);
                            break;
                    }
                }
                H0.a.y(iI014, parcel);
                return new C0088y(c12, f4, bArrJ, arrayListU4, dT, arrayListU5, c0077m, numV, l2, strQ6, c0070f);
            case 17:
                int iI015 = H0.a.i0(parcel);
                String strQ7 = null;
                String strQ8 = null;
                byte[] bArrJ2 = null;
                C0074j c0074j = null;
                C0073i c0073i = null;
                C0075k c0075k = null;
                C0071g c0071g = null;
                String strQ9 = null;
                while (parcel.dataPosition() < iI015) {
                    int i20 = parcel.readInt();
                    switch ((char) i20) {
                        case 1:
                            strQ7 = H0.a.q(i20, parcel);
                            break;
                        case 2:
                            strQ8 = H0.a.q(i20, parcel);
                            break;
                        case 3:
                            bArrJ2 = H0.a.j(i20, parcel);
                            break;
                        case 4:
                            c0074j = (C0074j) H0.a.o(parcel, i20, C0074j.CREATOR);
                            break;
                        case 5:
                            c0073i = (C0073i) H0.a.o(parcel, i20, C0073i.CREATOR);
                            break;
                        case k.STRING_SET_FIELD_NUMBER /* 6 */:
                            c0075k = (C0075k) H0.a.o(parcel, i20, C0075k.CREATOR);
                            break;
                        case k.DOUBLE_FIELD_NUMBER /* 7 */:
                            c0071g = (C0071g) H0.a.o(parcel, i20, C0071g.CREATOR);
                            break;
                        case k.BYTES_FIELD_NUMBER /* 8 */:
                            strQ9 = H0.a.q(i20, parcel);
                            break;
                        default:
                            H0.a.e0(i20, parcel);
                            break;
                    }
                }
                H0.a.y(iI015, parcel);
                return new C0087x(strQ7, strQ8, bArrJ2, c0074j, c0073i, c0075k, c0071g, strQ9);
            case 18:
                int iI016 = H0.a.i0(parcel);
                String strQ10 = null;
                byte[] bArrJ3 = null;
                ArrayList arrayListU6 = null;
                while (parcel.dataPosition() < iI016) {
                    int i21 = parcel.readInt();
                    char c13 = (char) i21;
                    if (c13 == 2) {
                        strQ10 = H0.a.q(i21, parcel);
                    } else if (c13 == 3) {
                        bArrJ3 = H0.a.j(i21, parcel);
                    } else if (c13 != 4) {
                        H0.a.e0(i21, parcel);
                    } else {
                        arrayListU6 = H0.a.u(parcel, i21, Transport.CREATOR);
                    }
                }
                H0.a.y(iI016, parcel);
                return new C0089z(strQ10, bArrJ3, arrayListU6);
            case 19:
                int iI017 = H0.a.i0(parcel);
                String strQ11 = null;
                Integer numV2 = null;
                while (parcel.dataPosition() < iI017) {
                    int i22 = parcel.readInt();
                    char c14 = (char) i22;
                    if (c14 == 2) {
                        strQ11 = H0.a.q(i22, parcel);
                    } else if (c14 != 3) {
                        H0.a.e0(i22, parcel);
                    } else {
                        numV2 = H0.a.V(i22, parcel);
                    }
                }
                H0.a.y(iI017, parcel);
                return new A(strQ11, numV2.intValue());
            case 20:
                int iI018 = H0.a.i0(parcel);
                byte[] bArrJ4 = null;
                Double dT2 = null;
                String strQ12 = null;
                ArrayList arrayListU7 = null;
                Integer numV3 = null;
                L l4 = null;
                String strQ13 = null;
                C0070f c0070f2 = null;
                Long lX = null;
                while (parcel.dataPosition() < iI018) {
                    int i23 = parcel.readInt();
                    switch ((char) i23) {
                        case 2:
                            bArrJ4 = H0.a.j(i23, parcel);
                            break;
                        case 3:
                            dT2 = H0.a.T(i23, parcel);
                            break;
                        case 4:
                            strQ12 = H0.a.q(i23, parcel);
                            break;
                        case 5:
                            arrayListU7 = H0.a.u(parcel, i23, C0089z.CREATOR);
                            break;
                        case k.STRING_SET_FIELD_NUMBER /* 6 */:
                            numV3 = H0.a.V(i23, parcel);
                            break;
                        case k.DOUBLE_FIELD_NUMBER /* 7 */:
                            l4 = (L) H0.a.o(parcel, i23, L.CREATOR);
                            break;
                        case k.BYTES_FIELD_NUMBER /* 8 */:
                            strQ13 = H0.a.q(i23, parcel);
                            break;
                        case '\t':
                            c0070f2 = (C0070f) H0.a.o(parcel, i23, C0070f.CREATOR);
                            break;
                        case '\n':
                            lX = H0.a.X(i23, parcel);
                            break;
                        default:
                            H0.a.e0(i23, parcel);
                            break;
                    }
                }
                H0.a.y(iI018, parcel);
                return new B(bArrJ4, dT2, strQ12, arrayListU7, numV3, l4, strQ13, c0070f2, lX);
            case 21:
                int iI019 = H0.a.i0(parcel);
                String strQ14 = null;
                String strQ15 = null;
                String strQ16 = null;
                while (parcel.dataPosition() < iI019) {
                    int i24 = parcel.readInt();
                    char c15 = (char) i24;
                    if (c15 == 2) {
                        strQ14 = H0.a.q(i24, parcel);
                    } else if (c15 == 3) {
                        strQ15 = H0.a.q(i24, parcel);
                    } else if (c15 != 4) {
                        H0.a.e0(i24, parcel);
                    } else {
                        strQ16 = H0.a.q(i24, parcel);
                    }
                }
                H0.a.y(iI019, parcel);
                return new C(strQ14, strQ15, strQ16);
            case 22:
                try {
                    return E.a(parcel.readString());
                } catch (D e5) {
                    throw new RuntimeException(e5);
                }
            case 23:
                int iI020 = H0.a.i0(parcel);
                byte[] bArrJ5 = null;
                String strQ17 = null;
                String strQ18 = null;
                String strQ19 = null;
                while (parcel.dataPosition() < iI020) {
                    int i25 = parcel.readInt();
                    char c16 = (char) i25;
                    if (c16 == 2) {
                        bArrJ5 = H0.a.j(i25, parcel);
                    } else if (c16 == 3) {
                        strQ17 = H0.a.q(i25, parcel);
                    } else if (c16 == 4) {
                        strQ18 = H0.a.q(i25, parcel);
                    } else if (c16 != 5) {
                        H0.a.e0(i25, parcel);
                    } else {
                        strQ19 = H0.a.q(i25, parcel);
                    }
                }
                H0.a.y(iI020, parcel);
                return new F(bArrJ5, strQ17, strQ18, strQ19);
            case 24:
                String string2 = parcel.readString();
                if (string2 == null) {
                    string2 = "";
                }
                try {
                    return I.a(string2);
                } catch (H e6) {
                    throw new RuntimeException(e6);
                }
            case 25:
                try {
                    return J.a(parcel.readString());
                } catch (K e7) {
                    throw new RuntimeException(e7);
                }
            case 26:
                int iI021 = H0.a.i0(parcel);
                String strQ20 = null;
                String strQ21 = null;
                while (parcel.dataPosition() < iI021) {
                    int i26 = parcel.readInt();
                    char c17 = (char) i26;
                    if (c17 == 2) {
                        strQ20 = H0.a.q(i26, parcel);
                    } else if (c17 != 3) {
                        H0.a.e0(i26, parcel);
                    } else {
                        strQ21 = H0.a.q(i26, parcel);
                    }
                }
                H0.a.y(iI021, parcel);
                return new L(strQ20, strQ21);
            case 27:
                int iI022 = H0.a.i0(parcel);
                boolean zS4 = false;
                while (parcel.dataPosition() < iI022) {
                    int i27 = parcel.readInt();
                    if (((char) i27) != 1) {
                        H0.a.e0(i27, parcel);
                    } else {
                        zS4 = H0.a.S(i27, parcel);
                    }
                }
                H0.a.y(iI022, parcel);
                return new M(zS4);
            case 28:
                try {
                    return V.a(parcel.readString());
                } catch (U e8) {
                    throw new RuntimeException(e8);
                }
            default:
                int iI023 = H0.a.i0(parcel);
                ArrayList arrayListU8 = null;
                while (parcel.dataPosition() < iI023) {
                    int i28 = parcel.readInt();
                    if (((char) i28) != 1) {
                        H0.a.e0(i28, parcel);
                    } else {
                        arrayListU8 = H0.a.u(parcel, i28, O.CREATOR);
                    }
                }
                H0.a.y(iI023, parcel);
                return new N(arrayListU8);
        }
    }

    @Override // android.os.Parcelable.Creator
    public final Object[] newArray(int i4) {
        switch (this.f136a) {
            case 0:
                return new b[i4];
            case 1:
                return new a[i4];
            case 2:
                return new d[i4];
            case 3:
                return new g[i4];
            case 4:
                return new h[i4];
            case 5:
                return new f[i4];
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                return new E0.d[i4];
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                return new F.k[i4];
            case k.BYTES_FIELD_NUMBER /* 8 */:
                return new Transport[i4];
            case 9:
                return new EnumC0067c[i4];
            case 10:
                return new c0[i4];
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                return new P[i4];
            case 12:
                return new Q[i4];
            case 13:
                return new C0086w[i4];
            case 14:
                return new M0.S[i4];
            case 15:
                return new T[i4];
            case 16:
                return new C0088y[i4];
            case 17:
                return new C0087x[i4];
            case 18:
                return new C0089z[i4];
            case 19:
                return new A[i4];
            case 20:
                return new B[i4];
            case 21:
                return new C[i4];
            case 22:
                return new E[i4];
            case 23:
                return new F[i4];
            case 24:
                return new I[i4];
            case 25:
                return new J[i4];
            case 26:
                return new L[i4];
            case 27:
                return new M[i4];
            case 28:
                return new V[i4];
            default:
                return new N[i4];
        }
    }
}
