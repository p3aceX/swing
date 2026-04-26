package M0;

import O.C0091b;
import O.C0092c;
import android.net.Uri;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.android.gms.fido.common.Transport;
import com.google.android.gms.fido.u2f.api.common.RegisterRequestParams;
import com.google.android.gms.fido.u2f.api.common.SignRequestParams;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class W implements Parcelable.Creator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f982a;

    public /* synthetic */ W(int i4) {
        this.f982a = i4;
    }

    @Override // android.os.Parcelable.Creator
    public final Object createFromParcel(Parcel parcel) {
        switch (this.f982a) {
            case 0:
                try {
                    return EnumC0069e.a(parcel.readString());
                } catch (C0068d e) {
                    throw new RuntimeException(e);
                }
            case 1:
                int iI0 = H0.a.i0(parcel);
                int iU = 0;
                short s4 = 0;
                short s5 = 0;
                while (parcel.dataPosition() < iI0) {
                    int i4 = parcel.readInt();
                    char c5 = (char) i4;
                    if (c5 == 1) {
                        iU = H0.a.U(i4, parcel);
                    } else if (c5 == 2) {
                        H0.a.n0(parcel, i4, 4);
                        s4 = (short) parcel.readInt();
                    } else if (c5 != 3) {
                        H0.a.e0(i4, parcel);
                    } else {
                        H0.a.n0(parcel, i4, 4);
                        s5 = (short) parcel.readInt();
                    }
                }
                H0.a.y(iI0, parcel);
                return new O(iU, s4, s5);
            case 2:
                int iI02 = H0.a.i0(parcel);
                N n4 = null;
                X x4 = null;
                C0072h c0072h = null;
                Y y4 = null;
                while (parcel.dataPosition() < iI02) {
                    int i5 = parcel.readInt();
                    char c6 = (char) i5;
                    if (c6 == 1) {
                        n4 = (N) H0.a.o(parcel, i5, N.CREATOR);
                    } else if (c6 == 2) {
                        x4 = (X) H0.a.o(parcel, i5, X.CREATOR);
                    } else if (c6 == 3) {
                        c0072h = (C0072h) H0.a.o(parcel, i5, C0072h.CREATOR);
                    } else if (c6 != 4) {
                        H0.a.e0(i5, parcel);
                    } else {
                        y4 = (Y) H0.a.o(parcel, i5, Y.CREATOR);
                    }
                }
                H0.a.y(iI02, parcel);
                return new C0071g(n4, x4, c0072h, y4);
            case 3:
                int iI03 = H0.a.i0(parcel);
                C0085v c0085v = null;
                a0 a0Var = null;
                M m4 = null;
                c0 c0Var = null;
                P p4 = null;
                Q q4 = null;
                b0 b0Var = null;
                S s6 = null;
                C0086w c0086w = null;
                T t4 = null;
                while (parcel.dataPosition() < iI03) {
                    int i6 = parcel.readInt();
                    switch ((char) i6) {
                        case 2:
                            c0085v = (C0085v) H0.a.o(parcel, i6, C0085v.CREATOR);
                            break;
                        case 3:
                            a0Var = (a0) H0.a.o(parcel, i6, a0.CREATOR);
                            break;
                        case 4:
                            m4 = (M) H0.a.o(parcel, i6, M.CREATOR);
                            break;
                        case 5:
                            c0Var = (c0) H0.a.o(parcel, i6, c0.CREATOR);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            p4 = (P) H0.a.o(parcel, i6, P.CREATOR);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            q4 = (Q) H0.a.o(parcel, i6, Q.CREATOR);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            b0Var = (b0) H0.a.o(parcel, i6, b0.CREATOR);
                            break;
                        case '\t':
                            s6 = (S) H0.a.o(parcel, i6, S.CREATOR);
                            break;
                        case '\n':
                            c0086w = (C0086w) H0.a.o(parcel, i6, C0086w.CREATOR);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            t4 = (T) H0.a.o(parcel, i6, T.CREATOR);
                            break;
                        default:
                            H0.a.e0(i6, parcel);
                            break;
                    }
                }
                H0.a.y(iI03, parcel);
                return new C0070f(c0085v, a0Var, m4, c0Var, p4, q4, b0Var, s6, c0086w, t4);
            case 4:
                int iI04 = H0.a.i0(parcel);
                boolean zS = false;
                while (parcel.dataPosition() < iI04) {
                    int i7 = parcel.readInt();
                    if (((char) i7) != 1) {
                        H0.a.e0(i7, parcel);
                    } else {
                        zS = H0.a.S(i7, parcel);
                    }
                }
                H0.a.y(iI04, parcel);
                return new C0072h(zS);
            case 5:
                int iI05 = H0.a.i0(parcel);
                byte[] bArrJ = null;
                byte[] bArrJ2 = null;
                while (parcel.dataPosition() < iI05) {
                    int i8 = parcel.readInt();
                    char c7 = (char) i8;
                    if (c7 == 1) {
                        bArrJ = H0.a.j(i8, parcel);
                    } else if (c7 != 2) {
                        H0.a.e0(i8, parcel);
                    } else {
                        bArrJ2 = H0.a.j(i8, parcel);
                    }
                }
                H0.a.y(iI05, parcel);
                return new X(bArrJ, bArrJ2);
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                int iI06 = H0.a.i0(parcel);
                byte[] bArrJ3 = null;
                boolean zS2 = false;
                while (parcel.dataPosition() < iI06) {
                    int i9 = parcel.readInt();
                    char c8 = (char) i9;
                    if (c8 == 1) {
                        zS2 = H0.a.S(i9, parcel);
                    } else if (c8 != 2) {
                        H0.a.e0(i9, parcel);
                    } else {
                        bArrJ3 = H0.a.j(i9, parcel);
                    }
                }
                H0.a.y(iI06, parcel);
                return new Y(bArrJ3, zS2);
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                int iI07 = H0.a.i0(parcel);
                byte[] bArrJ4 = null;
                byte[] bArrJ5 = null;
                byte[] bArrJ6 = null;
                byte[] bArrJ7 = null;
                byte[] bArrJ8 = null;
                while (parcel.dataPosition() < iI07) {
                    int i10 = parcel.readInt();
                    char c9 = (char) i10;
                    if (c9 == 2) {
                        bArrJ4 = H0.a.j(i10, parcel);
                    } else if (c9 == 3) {
                        bArrJ5 = H0.a.j(i10, parcel);
                    } else if (c9 == 4) {
                        bArrJ6 = H0.a.j(i10, parcel);
                    } else if (c9 == 5) {
                        bArrJ7 = H0.a.j(i10, parcel);
                    } else if (c9 != 6) {
                        H0.a.e0(i10, parcel);
                    } else {
                        bArrJ8 = H0.a.j(i10, parcel);
                    }
                }
                H0.a.y(iI07, parcel);
                return new C0073i(bArrJ4, bArrJ5, bArrJ6, bArrJ7, bArrJ8);
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                int iI08 = H0.a.i0(parcel);
                byte[] bArrJ9 = null;
                byte[] bArrJ10 = null;
                byte[] bArrJ11 = null;
                String[] strArr = null;
                while (parcel.dataPosition() < iI08) {
                    int i11 = parcel.readInt();
                    char c10 = (char) i11;
                    if (c10 == 2) {
                        bArrJ9 = H0.a.j(i11, parcel);
                    } else if (c10 == 3) {
                        bArrJ10 = H0.a.j(i11, parcel);
                    } else if (c10 == 4) {
                        bArrJ11 = H0.a.j(i11, parcel);
                    } else if (c10 != 5) {
                        H0.a.e0(i11, parcel);
                    } else {
                        int iY = H0.a.Y(i11, parcel);
                        int iDataPosition = parcel.dataPosition();
                        if (iY == 0) {
                            strArr = null;
                        } else {
                            String[] strArrCreateStringArray = parcel.createStringArray();
                            parcel.setDataPosition(iDataPosition + iY);
                            strArr = strArrCreateStringArray;
                        }
                    }
                }
                H0.a.y(iI08, parcel);
                return new C0074j(bArrJ9, bArrJ10, bArrJ11, strArr);
            case 9:
                int iI09 = H0.a.i0(parcel);
                int iU2 = 0;
                String strQ = null;
                int iU3 = 0;
                while (parcel.dataPosition() < iI09) {
                    int i12 = parcel.readInt();
                    char c11 = (char) i12;
                    if (c11 == 2) {
                        iU2 = H0.a.U(i12, parcel);
                    } else if (c11 == 3) {
                        strQ = H0.a.q(i12, parcel);
                    } else if (c11 != 4) {
                        H0.a.e0(i12, parcel);
                    } else {
                        iU3 = H0.a.U(i12, parcel);
                    }
                }
                H0.a.y(iI09, parcel);
                return new C0075k(iU2, strQ, iU3);
            case 10:
                int iI010 = H0.a.i0(parcel);
                String strQ2 = null;
                Boolean boolValueOf = null;
                String strQ3 = null;
                String strQ4 = null;
                while (parcel.dataPosition() < iI010) {
                    int i13 = parcel.readInt();
                    char c12 = (char) i13;
                    if (c12 == 2) {
                        strQ2 = H0.a.q(i13, parcel);
                    } else if (c12 == 3) {
                        int iY2 = H0.a.Y(i13, parcel);
                        if (iY2 == 0) {
                            boolValueOf = null;
                        } else {
                            H0.a.m0(parcel, iY2, 4);
                            boolValueOf = Boolean.valueOf(parcel.readInt() != 0);
                        }
                    } else if (c12 == 4) {
                        strQ3 = H0.a.q(i13, parcel);
                    } else if (c12 != 5) {
                        H0.a.e0(i13, parcel);
                    } else {
                        strQ4 = H0.a.q(i13, parcel);
                    }
                }
                H0.a.y(iI010, parcel);
                return new C0077m(strQ2, boolValueOf, strQ3, strQ4);
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                int iI011 = H0.a.i0(parcel);
                C0088y c0088y = null;
                Uri uri = null;
                byte[] bArrJ12 = null;
                while (parcel.dataPosition() < iI011) {
                    int i14 = parcel.readInt();
                    char c13 = (char) i14;
                    if (c13 == 2) {
                        c0088y = (C0088y) H0.a.o(parcel, i14, C0088y.CREATOR);
                    } else if (c13 == 3) {
                        uri = (Uri) H0.a.o(parcel, i14, Uri.CREATOR);
                    } else if (c13 != 4) {
                        H0.a.e0(i14, parcel);
                    } else {
                        bArrJ12 = H0.a.j(i14, parcel);
                    }
                }
                H0.a.y(iI011, parcel);
                return new C0078n(c0088y, uri, bArrJ12);
            case 12:
                int iI012 = H0.a.i0(parcel);
                B b5 = null;
                Uri uri2 = null;
                byte[] bArrJ13 = null;
                while (parcel.dataPosition() < iI012) {
                    int i15 = parcel.readInt();
                    char c14 = (char) i15;
                    if (c14 == 2) {
                        b5 = (B) H0.a.o(parcel, i15, B.CREATOR);
                    } else if (c14 == 3) {
                        uri2 = (Uri) H0.a.o(parcel, i15, Uri.CREATOR);
                    } else if (c14 != 4) {
                        H0.a.e0(i15, parcel);
                    } else {
                        bArrJ13 = H0.a.j(i15, parcel);
                    }
                }
                H0.a.y(iI012, parcel);
                return new C0079o(b5, uri2, bArrJ13);
            case 13:
                try {
                    return r.a(parcel.readInt());
                } catch (C0081q e4) {
                    throw new RuntimeException(e4);
                }
            case 14:
                int iI013 = H0.a.i0(parcel);
                byte[] bArrJ14 = null;
                byte[] bArrJ15 = null;
                byte[] bArrJ16 = null;
                long jW = 0;
                while (parcel.dataPosition() < iI013) {
                    int i16 = parcel.readInt();
                    char c15 = (char) i16;
                    if (c15 == 1) {
                        jW = H0.a.W(i16, parcel);
                    } else if (c15 == 2) {
                        bArrJ14 = H0.a.j(i16, parcel);
                    } else if (c15 == 3) {
                        bArrJ15 = H0.a.j(i16, parcel);
                    } else if (c15 != 4) {
                        H0.a.e0(i16, parcel);
                    } else {
                        bArrJ16 = H0.a.j(i16, parcel);
                    }
                }
                H0.a.y(iI013, parcel);
                return new Z(jW, bArrJ14, bArrJ15, bArrJ16);
            case 15:
                int iI014 = H0.a.i0(parcel);
                ArrayList arrayListU = null;
                while (parcel.dataPosition() < iI014) {
                    int i17 = parcel.readInt();
                    if (((char) i17) != 1) {
                        H0.a.e0(i17, parcel);
                    } else {
                        arrayListU = H0.a.u(parcel, i17, Z.CREATOR);
                    }
                }
                H0.a.y(iI014, parcel);
                return new a0(arrayListU);
            case 16:
                int iI015 = H0.a.i0(parcel);
                boolean zS3 = false;
                while (parcel.dataPosition() < iI015) {
                    int i18 = parcel.readInt();
                    if (((char) i18) != 1) {
                        H0.a.e0(i18, parcel);
                    } else {
                        zS3 = H0.a.S(i18, parcel);
                    }
                }
                H0.a.y(iI015, parcel);
                return new b0(zS3);
            case 17:
                try {
                    return EnumC0084u.a(parcel.readInt());
                } catch (C0083t e5) {
                    throw new IllegalArgumentException(e5);
                }
            case 18:
                int iI016 = H0.a.i0(parcel);
                String strQ5 = null;
                while (parcel.dataPosition() < iI016) {
                    int i19 = parcel.readInt();
                    if (((char) i19) != 2) {
                        H0.a.e0(i19, parcel);
                    } else {
                        strQ5 = H0.a.q(i19, parcel);
                    }
                }
                H0.a.y(iI016, parcel);
                return new C0085v(strQ5);
            case 19:
                try {
                    return N0.c.b(parcel.readInt());
                } catch (N0.b e6) {
                    throw new RuntimeException(e6);
                }
            case 20:
                int iI017 = H0.a.i0(parcel);
                String strQ6 = null;
                int iU4 = 0;
                String strQ7 = null;
                while (parcel.dataPosition() < iI017) {
                    int i20 = parcel.readInt();
                    char c16 = (char) i20;
                    if (c16 == 2) {
                        iU4 = H0.a.U(i20, parcel);
                    } else if (c16 == 3) {
                        strQ6 = H0.a.q(i20, parcel);
                    } else if (c16 != 4) {
                        H0.a.e0(i20, parcel);
                    } else {
                        strQ7 = H0.a.q(i20, parcel);
                    }
                }
                H0.a.y(iI017, parcel);
                return new N0.c(strQ6, iU4, strQ7);
            case 21:
                int iI018 = H0.a.i0(parcel);
                byte[] bArrJ17 = null;
                ArrayList arrayListU2 = null;
                int iU5 = 0;
                String strQ8 = null;
                while (parcel.dataPosition() < iI018) {
                    int i21 = parcel.readInt();
                    char c17 = (char) i21;
                    if (c17 == 1) {
                        iU5 = H0.a.U(i21, parcel);
                    } else if (c17 == 2) {
                        bArrJ17 = H0.a.j(i21, parcel);
                    } else if (c17 == 3) {
                        strQ8 = H0.a.q(i21, parcel);
                    } else if (c17 != 4) {
                        H0.a.e0(i21, parcel);
                    } else {
                        arrayListU2 = H0.a.u(parcel, i21, Transport.CREATOR);
                    }
                }
                H0.a.y(iI018, parcel);
                return new N0.d(iU5, bArrJ17, strQ8, arrayListU2);
            case 22:
                try {
                    return N0.f.a(parcel.readString());
                } catch (N0.e e7) {
                    throw new RuntimeException(e7);
                }
            case 23:
                int iI019 = H0.a.i0(parcel);
                String strQ9 = null;
                String strQ10 = null;
                int iU6 = 0;
                byte[] bArrJ18 = null;
                while (parcel.dataPosition() < iI019) {
                    int i22 = parcel.readInt();
                    char c18 = (char) i22;
                    if (c18 == 1) {
                        iU6 = H0.a.U(i22, parcel);
                    } else if (c18 == 2) {
                        strQ9 = H0.a.q(i22, parcel);
                    } else if (c18 == 3) {
                        bArrJ18 = H0.a.j(i22, parcel);
                    } else if (c18 != 4) {
                        H0.a.e0(i22, parcel);
                    } else {
                        strQ10 = H0.a.q(i22, parcel);
                    }
                }
                H0.a.y(iI019, parcel);
                return new N0.g(iU6, strQ9, bArrJ18, strQ10);
            case 24:
                int iI020 = H0.a.i0(parcel);
                Integer numV = null;
                Double dT = null;
                Uri uri3 = null;
                ArrayList arrayListU3 = null;
                ArrayList arrayListU4 = null;
                N0.c cVar = null;
                String strQ11 = null;
                while (parcel.dataPosition() < iI020) {
                    int i23 = parcel.readInt();
                    switch ((char) i23) {
                        case 2:
                            numV = H0.a.V(i23, parcel);
                            break;
                        case 3:
                            dT = H0.a.T(i23, parcel);
                            break;
                        case 4:
                            uri3 = (Uri) H0.a.o(parcel, i23, Uri.CREATOR);
                            break;
                        case 5:
                            arrayListU3 = H0.a.u(parcel, i23, N0.g.CREATOR);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            arrayListU4 = H0.a.u(parcel, i23, N0.h.CREATOR);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            cVar = (N0.c) H0.a.o(parcel, i23, N0.c.CREATOR);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            strQ11 = H0.a.q(i23, parcel);
                            break;
                        default:
                            H0.a.e0(i23, parcel);
                            break;
                    }
                }
                H0.a.y(iI020, parcel);
                return new RegisterRequestParams(numV, dT, uri3, arrayListU3, arrayListU4, cVar, strQ11);
            case 25:
                int iI021 = H0.a.i0(parcel);
                N0.d dVar = null;
                String strQ12 = null;
                String strQ13 = null;
                while (parcel.dataPosition() < iI021) {
                    int i24 = parcel.readInt();
                    char c19 = (char) i24;
                    if (c19 == 2) {
                        dVar = (N0.d) H0.a.o(parcel, i24, N0.d.CREATOR);
                    } else if (c19 == 3) {
                        strQ12 = H0.a.q(i24, parcel);
                    } else if (c19 != 4) {
                        H0.a.e0(i24, parcel);
                    } else {
                        strQ13 = H0.a.q(i24, parcel);
                    }
                }
                H0.a.y(iI021, parcel);
                return new N0.h(dVar, strQ12, strQ13);
            case 26:
                int iI022 = H0.a.i0(parcel);
                Integer numV2 = null;
                Double dT2 = null;
                Uri uri4 = null;
                byte[] bArrJ19 = null;
                ArrayList arrayListU5 = null;
                N0.c cVar2 = null;
                String strQ14 = null;
                while (parcel.dataPosition() < iI022) {
                    int i25 = parcel.readInt();
                    switch ((char) i25) {
                        case 2:
                            numV2 = H0.a.V(i25, parcel);
                            break;
                        case 3:
                            dT2 = H0.a.T(i25, parcel);
                            break;
                        case 4:
                            uri4 = (Uri) H0.a.o(parcel, i25, Uri.CREATOR);
                            break;
                        case 5:
                            bArrJ19 = H0.a.j(i25, parcel);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            arrayListU5 = H0.a.u(parcel, i25, N0.h.CREATOR);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            cVar2 = (N0.c) H0.a.o(parcel, i25, N0.c.CREATOR);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            strQ14 = H0.a.q(i25, parcel);
                            break;
                        default:
                            H0.a.e0(i25, parcel);
                            break;
                    }
                }
                H0.a.y(iI022, parcel);
                return new SignRequestParams(numV2, dT2, uri4, bArrJ19, arrayListU5, cVar2, strQ14);
            case 27:
                return new C0091b(parcel);
            case 28:
                return new C0092c(parcel);
            default:
                O.J j4 = new O.J();
                j4.f1218a = parcel.readString();
                j4.f1219b = parcel.readInt();
                return j4;
        }
    }

    @Override // android.os.Parcelable.Creator
    public final Object[] newArray(int i4) {
        switch (this.f982a) {
            case 0:
                return new EnumC0069e[i4];
            case 1:
                return new O[i4];
            case 2:
                return new C0071g[i4];
            case 3:
                return new C0070f[i4];
            case 4:
                return new C0072h[i4];
            case 5:
                return new X[i4];
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                return new Y[i4];
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                return new C0073i[i4];
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                return new C0074j[i4];
            case 9:
                return new C0075k[i4];
            case 10:
                return new C0077m[i4];
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                return new C0078n[i4];
            case 12:
                return new C0079o[i4];
            case 13:
                return new r[i4];
            case 14:
                return new Z[i4];
            case 15:
                return new a0[i4];
            case 16:
                return new b0[i4];
            case 17:
                return new EnumC0084u[i4];
            case 18:
                return new C0085v[i4];
            case 19:
                return new N0.a[i4];
            case 20:
                return new N0.c[i4];
            case 21:
                return new N0.d[i4];
            case 22:
                return new N0.f[i4];
            case 23:
                return new N0.g[i4];
            case 24:
                return new RegisterRequestParams[i4];
            case 25:
                return new N0.h[i4];
            case 26:
                return new SignRequestParams[i4];
            case 27:
                return new C0091b[i4];
            case 28:
                return new C0092c[i4];
            default:
                return new O.J[i4];
        }
    }
}
