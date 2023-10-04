########## Networking #############

resource "aws_vpc" "main" {
 cidr_block = var.vpc_cidr
 
 tags = {
   Name = "${var.basename}-vpc"
 }
}

resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.main.id
 
 tags = {
   Name = "${var.basename}-igw"
 }
}

# EIPs
resource "aws_eip" "eip_ngw" {
  domain   = "vpc"
}

# NAT GATEWAY
resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.eip_ngw.id
    subnet_id = aws_subnet.public_subnet["public-2"].id
    
    tags = {
      Name = "${var.basename}-natgateway"
    }

    depends_on = [ aws_eip.eip_ngw ]
}

# PUBLIC SUBNET(s)
resource "aws_subnet" "public_subnet" {
  for_each = var.public_subnet_list
 
  availability_zone = each.value["az"]
  cidr_block = each.value["cidr"]
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "${var.basename}-subnet-${each.key}"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${var.basename}-${var.cluster_name}" = "owned"
  }
}

# PRIVATE SUBNET(s)
resource "aws_subnet" "private_subnet" {
  for_each = var.private_subnet_list
 
  availability_zone = each.value["az"]
  cidr_block = each.value["cidr"]
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "${var.basename}-subnet-${each.key}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}



# ROUTE TABLES FOR PUBLIC SUBNETS
resource "aws_route_table" "pub_rt" {
    vpc_id = aws_vpc.main.id
    count = 3

    route {
        cidr_block = var.route_cidr
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
      Name = "${var.basename}-rwt"
    }
}


# ROUTE TABLES FOR PRIVATE SUBNETS
resource "aws_route_table" "pvt_rt" {
    vpc_id = aws_vpc.main.id
    count = 3

    route {
        cidr_block = var.route_cidr
        gateway_id = aws_nat_gateway.ngw.id
    }

    tags = {
      Name = "${var.basename}-private-rwt"
    }
}


# ROUTE TABLE ASSOCIATIONS 

# PUBLIC
resource "aws_route_table_association" "public_subnets_asso" {
  for_each = var.public_subnet_list
  subnet_id = aws_subnet.public_subnet[each.key].id 
  route_table_id = aws_route_table.pub_rt[each.value.index].id

}

# PRIVATE
resource "aws_route_table_association" "private_subnets_asso" {
  for_each = var.private_subnet_list
  subnet_id = aws_subnet.private_subnet[each.key].id 
  route_table_id = aws_route_table.pvt_rt[each.value.index].id

}
